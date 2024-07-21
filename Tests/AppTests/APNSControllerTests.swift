//
//  APNSControllerTests.swift
//
//  Created by Stavros Schizas on 21/7/24.
//

@testable import App
import XCTVapor

final class APNSControllerTests: XCTestCase {
    var app: Application!
    
    override func setUp() {
        self.app = try! Application.testable()
    }
    
    override func tearDown() {
        self.app.shutdown()
    }
    
    // MARK: Tests
    func testSendPushNotification() throws {
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
        self.app.shell = shellSpy
        shellSpy.stubbedIsProcessRunning = ProcessStatus.terminated
        shellSpy.stubbedRunCommandWithReturn = ""
        
        // When
        try app.test(.POST, "/apns", beforeRequest: { request in
            try request.content.encode(body, as: .json)
        }, afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .noContent)
            XCTAssertEqual(shellSpy.invokedRunCommandWithReturnCount, 1)
            XCTAssertTrue(shellSpy.invokedRunCommandWithReturnParameters?.command.contains("xcrun simctl push \(uuid) com.dummy.bundleID") ?? false)
        })
    }
    
    func testSendPushNotificationFailure() throws {
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
        self.app.shell = shellSpy
        shellSpy.stubbedIsProcessRunning = ProcessStatus.error
        shellSpy.stubbedRunCommandWithReturn = "error"
        shellSpy.stubbedRunCommandError = NSError(domain: "Foo", code: -1, userInfo: [:])
        
        // When
        try app.test(.POST, "/apns", beforeRequest: { request in
            try request.content.encode(body, as: .json)
        }, afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .internalServerError)
            XCTAssertEqual(shellSpy.invokedRunCommandWithReturnCount, 1)
            XCTAssertTrue(shellSpy.invokedRunCommandWithReturnParameters?.command.contains("xcrun simctl push \(uuid) com.dummy.bundleID") ?? false)
        })
    }
}
