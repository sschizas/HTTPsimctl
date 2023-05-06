//
//  OpenURLTests.swift
//  
//
//  Created by Stavros Schizas on 18/11/22.
//

@testable import App
import XCTVapor

final class OpenURLTests: XCTestCase {
    var app: Application!
    let openURLURI = "/open-url"
    
    override func setUp() {
        self.app = try! Application.testable()
    }
    
    override func tearDown() {
        self.app.shutdown()
    }
    
    // MARK: Tests
    func testPostSuccessWithoutSimulatorUDID() throws {
        // Given
        let shellSpy = ShellableSpy()
        let body = OpenURLRequestBody(urlToOpen: URL(string: "com.theblueground.dev.authorise://bluegroundappdev.page.link/sadasdasdas")!)
        self.app.shell = shellSpy

        // When
        try app.test(.POST, openURLURI, beforeRequest: { request in
            try request.content.encode(body, as: .json)
        }, afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .noContent)
            XCTAssertEqual(shellSpy.invokedRunCommandCount, 1)
            XCTAssertEqual(shellSpy.invokedRunCommandParameters.command, "xcrun simctl --set testing openurl booted \"com.theblueground.dev.authorise://bluegroundappdev.page.link/sadasdasdas\"")
        })
    }
    
    func testPostSuccessWithSimulatorUDID() throws {
        // Given
        let uuid = UUID()
        let shellSpy = ShellableSpy()
        let body = OpenURLRequestBody(
            urlToOpen: URL(string: "com.theblueground.dev.authorise://bluegroundappdev.page.link/sadasdasdas")!,
            simulatorUDID: uuid
        )
        self.app.shell = shellSpy
        
        // When
        try app.test(.POST, openURLURI, beforeRequest: { request in
            try request.content.encode(body, as: .json)
        }, afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .noContent)
            XCTAssertEqual(shellSpy.invokedRunCommandCount, 1)
            XCTAssertEqual(shellSpy.invokedRunCommandParameters.command, "xcrun simctl --set testing openurl \(uuid.uuidString) \"com.theblueground.dev.authorise://bluegroundappdev.page.link/sadasdasdas\"")
        })
    }
    
    func testPostBadRequestEmptyURLToOpen() throws {
        // Given
        let shellSpy = ShellableSpy()
        self.app.shell = shellSpy
        
        // When
        try app.test(.POST, openURLURI, beforeRequest: { request in
            try request.content.encode(["urlToOpen": ""])
        }, afterResponse: { response in
            // Then
            XCTAssertFalse(shellSpy.invokedRunCommand)
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testPostBadRequestEmptySimulatorUDID() throws {
        // Given
        let shellSpy = ShellableSpy()
        self.app.shell = shellSpy
        
        // When
        try app.test(.POST, openURLURI, beforeRequest: { request in
            try request.content.encode(["urlToOpen": "sdsdsds", "simulatorUDID": ""])
        }, afterResponse: { response in
            // Then
            XCTAssertFalse(shellSpy.invokedRunCommand)
            XCTAssertEqual(response.status, .badRequest)
        })
    }
}
