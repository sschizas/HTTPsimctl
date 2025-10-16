//
//  OpenURLTests.swift
//  
//
//  Created by Stavros Schizas on 18/11/22.
//

@testable import App
import VaporTesting
import Testing

@Suite("Open URL Tests")
struct OpenURLTests {
    let openURLURI = "/open-url"

    @Test("Post Success Without Simulator UDID Non Clone")
    func postSuccessWithoutSimulatorUDIDNonClone() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            let body = OpenURLRequestBody(
                urlToOpen: URL(string: "com.theblueground.dev.authorise://bluegroundappdev.page.link/sadasdasdas")!,
                isClone: false
            )
            app.shell = shellSpy

            // When
            try await app.testing().test(.POST, openURLURI, beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(response.status == .noContent)
                #expect(shellSpy.invokedRunCommandCount == 1)
                #expect(shellSpy.invokedRunCommandParameters.command == 
                    "xcrun simctl openurl booted \"com.theblueground.dev.authorise://bluegroundappdev.page.link/sadasdasdas\"")
            })
        }
    }

    @Test("Post Success Without Simulator UDID Clone")
    func postSuccessWithoutSimulatorUDIDClone() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            let body = OpenURLRequestBody(
                urlToOpen: URL(string: "com.theblueground.dev.authorise://bluegroundappdev.page.link/sadasdasdas")!,
                isClone: true
            )
            app.shell = shellSpy

            // When
            try await app.testing().test(.POST, openURLURI, beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(response.status == .noContent)
                #expect(shellSpy.invokedRunCommandCount == 1)
                #expect(shellSpy.invokedRunCommandParameters.command == 
                    "xcrun simctl --set testing openurl booted \"com.theblueground.dev.authorise://bluegroundappdev.page.link/sadasdasdas\"")
            })
        }
    }

    @Test("Post Success With Simulator UDID Non Clone")
    func postSuccessWithSimulatorUDIDNonClone() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let uuid = UUID()
            let shellSpy = ShellableSpy()
            let body = OpenURLRequestBody(
                urlToOpen: URL(string: "com.theblueground.dev.authorise://bluegroundappdev.page.link/sadasdasdas")!,
                simulatorUDID: uuid,
                isClone: false
            )
            app.shell = shellSpy

            // When
            try await app.testing().test(.POST, openURLURI, beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(response.status == .noContent)
                #expect(shellSpy.invokedRunCommandCount == 1)
                #expect(shellSpy.invokedRunCommandParameters.command == 
                    "xcrun simctl openurl \(uuid.uuidString) \"com.theblueground.dev.authorise://bluegroundappdev.page.link/sadasdasdas\"")
            })
        }
    }

    @Test("Post Success With Simulator UDID Clone")
    func postSuccessWithSimulatorUDIDClone() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let uuid = UUID()
            let shellSpy = ShellableSpy()
            let body = OpenURLRequestBody(
                urlToOpen: URL(string: "com.theblueground.dev.authorise://bluegroundappdev.page.link/sadasdasdas")!,
                simulatorUDID: uuid,
                isClone: true
            )
            app.shell = shellSpy

            // When
            try await app.testing().test(.POST, openURLURI, beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(response.status == .noContent)
                #expect(shellSpy.invokedRunCommandCount == 1)
                #expect(shellSpy.invokedRunCommandParameters.command == 
                    "xcrun simctl --set testing openurl \(uuid.uuidString) \"com.theblueground.dev.authorise://bluegroundappdev.page.link/sadasdasdas\"")
            })
        }
    }

    @Test("Post Bad Request Empty URL To Open")
    func postBadRequestEmptyURLToOpen() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            app.shell = shellSpy

            // When
            try await app.testing().test(.POST, openURLURI, beforeRequest: { request in
                try request.content.encode(["urlToOpen": ""])
            }, afterResponse: { response async in
                // Then
                #expect(!shellSpy.invokedRunCommand)
                #expect(response.status == .badRequest)
            })
        }
    }

    @Test("Post Bad Request Empty Simulator UDID")
    func postBadRequestEmptySimulatorUDID() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            app.shell = shellSpy

            // When
            try await app.testing().test(.POST, openURLURI, beforeRequest: { request in
                try request.content.encode(["urlToOpen": "sdsdsds", "simulatorUDID": ""])
            }, afterResponse: { response async in
                // Then
                #expect(!shellSpy.invokedRunCommand)
                #expect(response.status == .badRequest)
            })
        }
    }
}
