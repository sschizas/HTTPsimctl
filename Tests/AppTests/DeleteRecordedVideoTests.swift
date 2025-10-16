//
//  DeleteRecordedVideoTests.swift
//  
//
//  Created by Stavros Schizas on 11/5/23.
//

@testable import App
import VaporTesting
import Testing

@Suite("Delete Recorded Video Tests")
struct DeleteRecordedVideoTests {

    @Test("Delete Recorded Video")
    func deleteRecordedVideo() async throws {
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
            try await app.testing().test(.DELETE, "/record-video", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(response.status == .ok)
                #expect(shellSpy.invokedRunCommandCount == 2)
                let commands = shellSpy.invokedRunCommandParametersList.map { $0.command }
                #expect(commands.contains("kill -s SIGINT \(pid)"))
                #expect(commands.contains("rm \(filepath).mp4"))
            })
        }
    }
}
