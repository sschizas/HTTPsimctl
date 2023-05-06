//
//  DeleteRecordedVideoTests.swift
//  
//
//  Created by Stavros Schizas on 11/5/23.
//

@testable import App
import XCTVapor

final class DeleteRecordedVideoTests: XCTestCase {
    var app: Application!
    
    override func setUp() {
        self.app = try! Application.testable()
    }
    
    override func tearDown() {
        self.app.shutdown()
    }

    // MARK: Tests
    func testDeleteRecordedVideo() throws {
        // Given
        let pid = 12352
        let filepath = "foo4"
        let shellSpy = ShellableSpy()
        let body = StopRecordingVideoRequestBody(pid: pid, fileName: filepath)
        self.app.shell = shellSpy
        shellSpy.stubbedIsProcessRunning = false
        shellSpy.stubbedRunCommandWithReturn = filepath
        
        // When
        try app.test(.DELETE, "/record-video", beforeRequest: { request in
            try request.content.encode(body, as: .json)
        }, afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(shellSpy.invokedRunCommandCount, 2)
            let commands = shellSpy.invokedRunCommandParametersList.map { $0.command
            }
            XCTAssertTrue(commands.contains("kill -s SIGINT \(pid)"))
            XCTAssertTrue(commands.contains("rm \(filepath).mp4"))
        })
    }
}
