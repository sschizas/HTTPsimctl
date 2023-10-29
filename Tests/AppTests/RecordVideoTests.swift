//
//  RecordVideoTests.swift
//
//  Created by Stavros Schizas on 1/4/23.
//

@testable import App
import XCTVapor

final class RecordVideoTests: XCTestCase {
    var app: Application!
    
    override func setUp() {
        self.app = try! Application.testable()
    }
    
    override func tearDown() {
        self.app.shutdown()
    }
    
    // MARK: Tests
    func testPostRecordVideoWithoutSimulatorUDIDNonClone() throws {
        // Given
        let pid = 12_352
        let shellSpy = ShellableSpy()
        let body = RecordVideoRequestBody(fileName: "foo", isClone: false)
        self.app.shell = shellSpy
        shellSpy.stubbedRunCommandWithReturn = pid.description
        shellSpy.stubbedIsProcessRunning = false
        
        // When
        try app.test(.POST, "/record-video/start", beforeRequest: { request in
            try request.content.encode(body, as: .json)
        }, afterResponse: { response in
            // Then
            let responseBody = try response.content.decode(RecordVideoResponse.self)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(responseBody.pid, pid)
            XCTAssertEqual(shellSpy.invokedRunCommandWithReturnCount, 1)
            XCTAssertEqual(shellSpy.invokedRunCommandWithReturnParameters.command, "xcrun simctl io booted recordVideo --codec=h264 --force foo.mp4 >/dev/null 2>&1 & echo $!")
        })
    }
    
    func testPostRecordVideoWithoutSimulatorUDIDClone() throws {
        // Given
        let pid = 12_352
        let shellSpy = ShellableSpy()
        let body = RecordVideoRequestBody(fileName: "foo", isClone: true)
        self.app.shell = shellSpy
        shellSpy.stubbedRunCommandWithReturn = pid.description
        shellSpy.stubbedIsProcessRunning = false
        
        // When
        try app.test(.POST, "/record-video/start", beforeRequest: { request in
            try request.content.encode(body, as: .json)
        }, afterResponse: { response in
            // Then
            let responseBody = try response.content.decode(RecordVideoResponse.self)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(responseBody.pid, pid)
            XCTAssertEqual(shellSpy.invokedRunCommandWithReturnCount, 1)
            XCTAssertEqual(shellSpy.invokedRunCommandWithReturnParameters.command, "xcrun simctl --set testing io booted recordVideo --codec=h264 --force foo.mp4 >/dev/null 2>&1 & echo $!")
        })
    }
    
    func testPostRecordVideoWithSimulatorUDID() throws {
        // Given
        let pid = 12_352
        let uuid = UUID()
        let shellSpy = ShellableSpy()
        let body = RecordVideoRequestBody(fileName: "foo", simulatorUDID: uuid, isClone: false)
        self.app.shell = shellSpy
        shellSpy.stubbedRunCommandWithReturn = pid.description
        
        // When
        try app.test(.POST, "/record-video/start", beforeRequest: { request in
            try request.content.encode(body, as: .json)
        }, afterResponse: { response in
            // Then
            let responseBody = try response.content.decode(RecordVideoResponse.self)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(responseBody.pid, pid)
            XCTAssertEqual(shellSpy.invokedRunCommandWithReturnCount, 1)
            XCTAssertEqual(shellSpy.invokedRunCommandWithReturnParameters.command, "xcrun simctl io \(uuid.uuidString) recordVideo --codec=h264 --force foo.mp4 >/dev/null 2>&1 & echo $!")
        })
    }
    
    func testPostBadRequestEmptyFilename() throws {
        // Given
        let pid = 12_352
        let shellSpy = ShellableSpy()
        let body = RecordVideoRequestBody(fileName: "", isClone: false)
        self.app.shell = shellSpy
        shellSpy.stubbedRunCommandWithReturn = pid.description
        
        // When
        try app.test(.POST, "/record-video/start", beforeRequest: { request in
            try request.content.encode(body, as: .json)
        }, afterResponse: { response in
            // Then
            XCTAssertFalse(shellSpy.invokedRunCommandWithReturn)
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testPostBadRequestFilenameInvalidLenght() throws {
        // Given
        let pid = 12_352
        let shellSpy = ShellableSpy()
        let body = RecordVideoRequestBody(fileName: "ab", isClone: false)
        self.app.shell = shellSpy
        shellSpy.stubbedRunCommandWithReturn = pid.description
        
        // When
        try app.test(.POST, "/record-video/start", beforeRequest: { request in
            try request.content.encode(body, as: .json)
        }, afterResponse: { response in
            // Then
            XCTAssertFalse(shellSpy.invokedRunCommandWithReturn)
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testPostBadRequestFilenameInvalidFormat() throws {
        // Given
        let pid = 12_352
        let shellSpy = ShellableSpy()
        let body = RecordVideoRequestBody(fileName: "ab123@", isClone: false)
        self.app.shell = shellSpy
        shellSpy.stubbedRunCommandWithReturn = pid.description
        
        // When
        try app.test(.POST, "/record-video/start", beforeRequest: { request in
            try request.content.encode(body, as: .json)
        }, afterResponse: { response in
            // Then
            XCTAssertFalse(shellSpy.invokedRunCommandWithReturn)
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testPostBadRequestEmptySimulatorUDID() throws {
        // Given
        let pid = 12_352
        let shellSpy = ShellableSpy()
        self.app.shell = shellSpy
        shellSpy.stubbedRunCommandWithReturn = pid.description
        
        // When
        try app.test(.POST, "/record-video/start", beforeRequest: { request in
            try request.content.encode(["fileName": "sdsdsds", "simulatorUDID": ""])
        }, afterResponse: { response in
            // Then
            XCTAssertFalse(shellSpy.invokedRunCommandWithReturn)
            XCTAssertEqual(response.status, .badRequest)
        })
    }
}
