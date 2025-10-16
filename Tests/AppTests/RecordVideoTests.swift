//
//  RecordVideoTests.swift
//
//  Created by Stavros Schizas on 1/4/23.
//

@testable import App
import VaporTesting
import Testing

@Suite("Record Video Tests")
struct RecordVideoTests {

    @Test("Post Record Video Without Simulator UDID Non Clone")
    func postRecordVideoWithoutSimulatorUDIDNonClone() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let pid = 12_352
            let shellSpy = ShellableSpy()
            let body = RecordVideoRequestBody(fileName: "foo", isClone: false)
            app.shell = shellSpy
            shellSpy.stubbedRunCommandWithReturn = pid.description
            shellSpy.stubbedIsProcessRunning = ProcessStatus.terminated
            _ = try await app.cache.set("foo", to: "\(pid)")

            // When
            try await app.testing().test(.POST, "/record-video/start", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(response.status == .ok)
                #expect(shellSpy.invokedRunCommandWithReturnCount == 1)
                #expect(shellSpy.invokedRunCommandWithReturnParameters.command == 
                    "xcrun simctl io booted recordVideo --codec=h264 --force foo.mp4 >/dev/null 2>&1 & echo $!")
            })
        }
    }

    @Test("Post Record Video Without Simulator UDID Clone")
    func postRecordVideoWithoutSimulatorUDIDClone() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let pid = 12_352
            let shellSpy = ShellableSpy()
            let body = RecordVideoRequestBody(fileName: "foo", isClone: true)
            app.shell = shellSpy
            shellSpy.stubbedRunCommandWithReturn = pid.description
            shellSpy.stubbedIsProcessRunning = ProcessStatus.terminated
            _ = try await app.cache.set("foo", to: "\(pid)")

            // When
            try await app.testing().test(.POST, "/record-video/start", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(response.status == .ok)
                #expect(shellSpy.invokedRunCommandWithReturnCount == 1)
                #expect(shellSpy.invokedRunCommandWithReturnParameters.command == 
                    "xcrun simctl --set testing io booted recordVideo --codec=h264 --force foo.mp4 >/dev/null 2>&1 & echo $!")
            })
        }
    }

    @Test("Post Record Video With Simulator UDID")
    func postRecordVideoWithSimulatorUDID() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let pid = 12_352
            let uuid = UUID()
            let shellSpy = ShellableSpy()
            let body = RecordVideoRequestBody(fileName: "foo", simulatorUDID: uuid, isClone: false)
            app.shell = shellSpy
            shellSpy.stubbedRunCommandWithReturn = pid.description

            // When
            try await app.testing().test(.POST, "/record-video/start", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(response.status == .ok)
                #expect(shellSpy.invokedRunCommandWithReturnCount == 1)
                #expect(shellSpy.invokedRunCommandWithReturnParameters.command == 
                    "xcrun simctl io \(uuid.uuidString) recordVideo --codec=h264 --force foo.mp4 >/dev/null 2>&1 & echo $!")
            })
        }
    }

    @Test("Post Bad Request Empty Filename")
    func postBadRequestEmptyFilename() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let pid = 12_352
            let shellSpy = ShellableSpy()
            let body = RecordVideoRequestBody(fileName: "", isClone: false)
            app.shell = shellSpy
            shellSpy.stubbedRunCommandWithReturn = pid.description

            // When
            try await app.testing().test(.POST, "/record-video/start", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(!shellSpy.invokedRunCommandWithReturn)
                #expect(response.status == .badRequest)
            })
        }
    }

    @Test("Post Bad Request Filename Invalid Length")
    func postBadRequestFilenameInvalidLength() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let pid = 12_352
            let shellSpy = ShellableSpy()
            let body = RecordVideoRequestBody(fileName: "ab", isClone: false)
            app.shell = shellSpy
            shellSpy.stubbedRunCommandWithReturn = pid.description

            // When
            try await app.testing().test(.POST, "/record-video/start", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(!shellSpy.invokedRunCommandWithReturn)
                #expect(response.status == .badRequest)
            })
        }
    }

    @Test("Post Bad Request Filename Invalid Format")
    func postBadRequestFilenameInvalidFormat() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let pid = 12_352
            let shellSpy = ShellableSpy()
            let body = RecordVideoRequestBody(fileName: "ab123@", isClone: false)
            app.shell = shellSpy
            shellSpy.stubbedRunCommandWithReturn = pid.description

            // When
            try await app.testing().test(.POST, "/record-video/start", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(!shellSpy.invokedRunCommandWithReturn)
                #expect(response.status == .badRequest)
            })
        }
    }

    @Test("Post Bad Request Empty Simulator UDID")
    func postBadRequestEmptySimulatorUDID() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let pid = 12_352
            let shellSpy = ShellableSpy()
            app.shell = shellSpy
            shellSpy.stubbedRunCommandWithReturn = pid.description

            // When
            try await app.testing().test(.POST, "/record-video/start", beforeRequest: { request in
                try request.content.encode(["fileName": "sdsdsds", "simulatorUDID": ""])
            }, afterResponse: { response async in
                // Then
                #expect(!shellSpy.invokedRunCommandWithReturn)
                #expect(response.status == .badRequest)
            })
        }
    }
}
