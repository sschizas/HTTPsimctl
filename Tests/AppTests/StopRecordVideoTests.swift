//
//  StopRecordVideoTests.swift
//  
//
//  Created by Stavros Schizas on 11/5/23.
//

@testable import App
import VaporTesting
import Testing

@Suite("Stop Record Video Tests")
struct StopRecordVideoTests {

    @Test("Stop Record Video")
    func stopRecordVideo() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let pid = 12_352
            let filepath = "foo4"
            let shellSpy = ShellableSpy()
            let body = StopRecordingVideoRequestBody(fileName: filepath)
            app.shell = shellSpy
            shellSpy.stubbedIsProcessRunning = ProcessStatus.terminated
            shellSpy.stubbedRunCommandWithReturn = filepath
            _ = try await app.cache.set(filepath, to: "\(pid)")

            // When
            try await app.testing().test(.POST, "/record-video/stop", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async throws in
                // Then
                let responseBody = try response.content.decode(StopRecordingVideoResponse.self)
                #expect(response.status == .ok)
                #expect(responseBody.filePath == filepath)
                #expect(shellSpy.invokedRunCommandWithReturnCount == 1)
                #expect(shellSpy.invokedRunCommandWithReturnParameters.command == "realpath foo4.mp4")
                #expect(shellSpy.invokedRunCommandCount == 1)
                #expect(shellSpy.invokedRunCommandParameters.command == "kill -s SIGINT 12352")
            })
        }
    }

    @Test("Stop Record Video Empty Filename")
    func stopRecordVideoEmptyFilename() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let pid = 12_352
            let filepath = ""
            let shellSpy = ShellableSpy()
            let body = StopRecordingVideoRequestBody(fileName: filepath)
            app.shell = shellSpy
            shellSpy.stubbedIsProcessRunning = ProcessStatus.terminated
            shellSpy.stubbedRunCommandWithReturn = filepath
            _ = try await app.cache.set(filepath, to: "\(pid)")

            // When
            try await app.testing().test(.POST, "/record-video/stop", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(!shellSpy.invokedRunCommandWithReturn)
                #expect(!shellSpy.invokedRunCommand)
                #expect(response.status == .badRequest)
            })
        }
    }
}
