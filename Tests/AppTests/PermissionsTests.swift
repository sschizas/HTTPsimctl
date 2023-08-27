//
//  PermissionsTests.swift
//
//  Created by Stavros Schizas on 10/9/23.
//

@testable import App
import XCTVapor

final class PermissionsTests: XCTestCase {
    var app: Application!
    
    override func setUp() {
        self.app = try! Application.testable()
    }
    
    override func tearDown() {
        self.app.shutdown()
    }
    
    // MARK: Tests
    func testGrantPermissionBadRequestMissingPermission() throws {
        // Given
        let shellSpy = ShellableSpy()
        self.app.shell = shellSpy
        
        // When
        try app.test(.POST, "/permission/grant", beforeRequest: { request in
            try request.content.encode(["appBundleId": "sdsdsds"])
        }, afterResponse: { response in
            // Then
            XCTAssertFalse(shellSpy.invokedRunCommandWithReturn)
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testRevokePermissionBadRequestMissingPermission() throws {
        // Given
        let shellSpy = ShellableSpy()
        self.app.shell = shellSpy
        
        // When
        try app.test(.POST, "/permission/revoke", beforeRequest: { request in
            try request.content.encode(["appBundleId": "sdsdsds"])
        }, afterResponse: { response in
            // Then
            XCTAssertFalse(shellSpy.invokedRunCommandWithReturn)
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testGrantPermissionBadRequestUnknownPermission() throws {
        // Given
        let shellSpy = ShellableSpy()
        self.app.shell = shellSpy
        
        // When
        try app.test(.POST, "/permission/grant", beforeRequest: { request in
            try request.content.encode(["appBundleId": "sdsdsds", "permission": "test"])
        }, afterResponse: { response in
            // Then
            XCTAssertFalse(shellSpy.invokedRunCommandWithReturn)
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testRevokePermissionBadRequestUnknownPermission() throws {
        // Given
        let shellSpy = ShellableSpy()
        self.app.shell = shellSpy
        
        // When
        try app.test(.POST, "/permission/revoke", beforeRequest: { request in
            try request.content.encode(["appBundleId": "sdsdsds", "permission": "test"])
        }, afterResponse: { response in
            // Then
            XCTAssertFalse(shellSpy.invokedRunCommandWithReturn)
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testGrantPermissionBadRequestMissingAppBundleID() throws {
        // Given
        let shellSpy = ShellableSpy()
        self.app.shell = shellSpy
        
        // When
        try app.test(.POST, "/permission/grant", beforeRequest: { request in
            try request.content.encode(["permission": "test"])
        }, afterResponse: { response in
            // Then
            XCTAssertFalse(shellSpy.invokedRunCommandWithReturn)
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testRevokePermissionBadRequestMissingAppBundleID() throws {
        // Given
        let shellSpy = ShellableSpy()
        self.app.shell = shellSpy
        
        // When
        try app.test(.POST, "/permission/revoke", beforeRequest: { request in
            try request.content.encode(["permission": "test"])
        }, afterResponse: { response in
            // Then
            XCTAssertFalse(shellSpy.invokedRunCommandWithReturn)
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testGrantPermission() throws {
        // Given
        let shellSpy = ShellableSpy()
        self.app.shell = shellSpy
        let uuid = UUID()
        
        // When
        try app.test(.POST, "/permission/grant", beforeRequest: { request in
            try request.content.encode(
                [
                    "appBundleId": "sdsdsds",
                    "permission": "photos-add",
                    "simulatorUDID": uuid.uuidString
                ]
            )
        }, afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .noContent)
            XCTAssertEqual(shellSpy.invokedRunCommandCount, 1)
            XCTAssertEqual(shellSpy.invokedRunCommandParameters.command, "xcrun simctl --set testing privacy \(uuid.uuidString) grant photos-add sdsdsds")
        })
    }
    
    func testRevokePermission() throws {
        // Given
        let shellSpy = ShellableSpy()
        self.app.shell = shellSpy
        let uuid = UUID()
        
        // When
        try app.test(.POST, "/permission/revoke", beforeRequest: { request in
            try request.content.encode(
                [
                    "appBundleId": "sdsdsds",
                    "permission": "photos-add",
                    "simulatorUDID": uuid.uuidString
                ]
            )
        }, afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .noContent)
            XCTAssertEqual(shellSpy.invokedRunCommandCount, 1)
            XCTAssertEqual(shellSpy.invokedRunCommandParameters.command, "xcrun simctl --set testing privacy \(uuid.uuidString) revoke photos-add sdsdsds")
        })
    }
}
