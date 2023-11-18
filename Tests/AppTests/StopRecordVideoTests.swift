//
//  StopRecordVideoTests.swift
//  
//
//  Created by Stavros Schizas on 11/5/23.
//

@testable import App
import XCTVapor

final class StopRecordVideoTests: XCTestCase {
    var app: Application!
    
    override func setUp() {
        self.app = try! Application.testable()
    }
    
    override func tearDown() {
        self.app.shutdown()
    }
    
    // MARK: Tests
    func testStopRecordVideo() throws {
        // Given
        let pid = 12_352
        let filepath = "foo4"
        let shellSpy = ShellableSpy()
        let body = StopRecordingVideoRequestBody(fileName: filepath)
        self.app.shell = shellSpy
        shellSpy.stubbedIsProcessRunning = ProcessStatus.terminated
        shellSpy.stubbedRunCommandWithReturn = filepath
        _ = self.app.cache.set(filepath, to: "\(pid)")
        
        // When
        try app.test(.POST, "/record-video/stop", beforeRequest: { request in
            try request.content.encode(body, as: .json)
        }, afterResponse: { response in
            // Then
            let responseBody = try response.content.decode(StopRecordingVideoResponse.self)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(responseBody.filePath, filepath)
            XCTAssertEqual(shellSpy.invokedRunCommandWithReturnCount, 1)
            XCTAssertEqual(shellSpy.invokedRunCommandWithReturnParameters.command, "realpath foo4.mp4")
            XCTAssertEqual(shellSpy.invokedRunCommandCount, 1)
            XCTAssertEqual(shellSpy.invokedRunCommandParameters.command, "kill -s SIGINT 12352")
        })
    }
    
    func testStopRecordVideoEmptyFilename() throws {
        // Given
        let pid = 12_352
        let filepath = ""
        let shellSpy = ShellableSpy()
        let body = StopRecordingVideoRequestBody(fileName: filepath)
        self.app.shell = shellSpy
        shellSpy.stubbedIsProcessRunning = ProcessStatus.terminated
        shellSpy.stubbedRunCommandWithReturn = filepath
        _ = self.app.cache.set(filepath, to: "\(pid)")
        
        // When
        try app.test(.POST, "/record-video/stop", beforeRequest: { request in
            try request.content.encode(body, as: .json)
        }, afterResponse: { response in
            // Then
            XCTAssertFalse(shellSpy.invokedRunCommandWithReturn)
            XCTAssertFalse(shellSpy.invokedRunCommand)
            XCTAssertEqual(response.status, .badRequest)
        })
    }
}
