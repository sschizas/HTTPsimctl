//
//  APNSControllerTests.swift
//
//  Created by Stavros Schizas on 21/7/24.
//

@testable import App
import VaporTesting
import Testing

@Suite("APNS Controller Tests")
struct APNSControllerTests {

    @Test("Send Push Notification")
    func sendPushNotification() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let uuid = UUID()
            let shellSpy = ShellableSpy()
            let apnsPayload = """
                {
                    "SimulatorTargetBundle":"com.dummy.app",
                    "aps":{
                        "alert":{
                            "title":"TransferUpdate",
                            "body":"YourTransferhasbeendownloaded"
                        }
                    }
                }
                """
            let body = APNSRequestBody(
                apns: apnsPayload,
                simulatorUDID: uuid,
                isClone: false,
                appBundleId: "com.dummy.bundleID"
            )
            app.shell = shellSpy
            shellSpy.stubbedIsProcessRunning = ProcessStatus.terminated
            shellSpy.stubbedRunCommandWithReturn = ""

            // When
            try await app.testing().test(.POST, "/apns", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(response.status == .noContent)
                #expect(shellSpy.invokedRunCommandWithReturnCount == 1)
                #expect(shellSpy.invokedRunCommandWithReturnParameters?.command.contains(
                    "xcrun simctl push \(uuid) com.dummy.bundleID") ?? false)
            })
        }
    }

    @Test("Send Push Notification Failure")
    func sendPushNotificationFailure() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let uuid = UUID()
            let shellSpy = ShellableSpy()
            let apnsPayload = """
                {
                    "SimulatorTargetBundle":"com.dummy.app",
                    "aps":{
                        "alert":{
                            "title":"TransferUpdate",
                            "body":"YourTransferhasbeendownloaded"
                        }
                    }
                }
                """
            let body = APNSRequestBody(
                apns: apnsPayload,
                simulatorUDID: uuid,
                isClone: false,
                appBundleId: "com.dummy.bundleID"
            )
            app.shell = shellSpy
            shellSpy.stubbedIsProcessRunning = ProcessStatus.error
            shellSpy.stubbedRunCommandWithReturn = "error"
            shellSpy.stubbedRunCommandWithReturnError = Shell.Error.commandFailed(
                command: "xcrun simctl push",
                exitCode: 1,
                stderr: "An error was encountered processing the command"
            )

            // When
            try await app.testing().test(.POST, "/apns", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async throws in
                // Then
                #expect(response.status == .internalServerError)
                let error = try response.content.decode(ErrorBody.self)
                #expect(error.reason.contains("An error was encountered processing the command"))
                #expect(shellSpy.invokedRunCommandWithReturnCount == 1)
                #expect(shellSpy.invokedRunCommandWithReturnParameters?.command.contains(
                    "xcrun simctl push \(uuid) com.dummy.bundleID") ?? false)
            })
        }
    }
}
