//
//  PermissionsTests.swift
//
//  Created by Stavros Schizas on 10/9/23.
//

@testable import App
import VaporTesting
import Testing

@Suite("Permissions Tests")
struct PermissionsTests {

    @Test("Grant Permission Bad Request Missing Permission")
    func grantPermissionBadRequestMissingPermission() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            app.shell = shellSpy

            // When
            try await app.testing().test(.POST, "/permission/grant", beforeRequest: { request in
                try request.content.encode(["appBundleId": "sdsdsds"])
            }, afterResponse: { response async in
                // Then
                #expect(!shellSpy.invokedRunCommandWithReturn)
                #expect(response.status == .badRequest)
            })
        }
    }

    @Test("Revoke Permission Bad Request Missing Permission")
    func revokePermissionBadRequestMissingPermission() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            app.shell = shellSpy

            // When
            try await app.testing().test(.POST, "/permission/revoke", beforeRequest: { request in
                try request.content.encode(["appBundleId": "sdsdsds"])
            }, afterResponse: { response async in
                // Then
                #expect(!shellSpy.invokedRunCommandWithReturn)
                #expect(response.status == .badRequest)
            })
        }
    }

    @Test("Grant Permission Bad Request Unknown Permission")
    func grantPermissionBadRequestUnknownPermission() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            app.shell = shellSpy

            // When
            try await app.testing().test(.POST, "/permission/grant", beforeRequest: { request in
                try request.content.encode(["appBundleId": "sdsdsds", "permission": "test"])
            }, afterResponse: { response async in
                // Then
                #expect(!shellSpy.invokedRunCommandWithReturn)
                #expect(response.status == .badRequest)
            })
        }
    }

    @Test("Revoke Permission Bad Request Unknown Permission")
    func revokePermissionBadRequestUnknownPermission() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            app.shell = shellSpy

            // When
            try await app.testing().test(.POST, "/permission/revoke", beforeRequest: { request in
                try request.content.encode(["appBundleId": "sdsdsds", "permission": "test"])
            }, afterResponse: { response async in
                // Then
                #expect(!shellSpy.invokedRunCommandWithReturn)
                #expect(response.status == .badRequest)
            })
        }
    }

    @Test("Grant Permission Bad Request Missing App Bundle ID")
    func grantPermissionBadRequestMissingAppBundleID() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            app.shell = shellSpy

            // When
            try await app.testing().test(.POST, "/permission/grant", beforeRequest: { request in
                try request.content.encode(["permission": "test"])
            }, afterResponse: { response async in
                // Then
                #expect(!shellSpy.invokedRunCommandWithReturn)
                #expect(response.status == .badRequest)
            })
        }
    }

    @Test("Revoke Permission Bad Request Missing App Bundle ID")
    func revokePermissionBadRequestMissingAppBundleID() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            app.shell = shellSpy

            // When
            try await app.testing().test(.POST, "/permission/revoke", beforeRequest: { request in
                try request.content.encode(["permission": "test"])
            }, afterResponse: { response async in
                // Then
                #expect(!shellSpy.invokedRunCommandWithReturn)
                #expect(response.status == .badRequest)
            })
        }
    }

    @Test("Grant Permission Non Clone")
    func grantPermissionNonClone() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            app.shell = shellSpy
            let uuid = UUID()

            // When
            let body = PermissionRequestBody(
                permission: PermissionRequestBody.Permission.addPhotos,
                appBundleId: "sdsdsds",
                simulatorUDID: uuid,
                isClone: false
            )
            try await app.testing().test(.POST, "/permission/grant", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(response.status == .noContent)
                #expect(shellSpy.invokedRunCommandCount == 1)
                #expect(shellSpy.invokedRunCommandParameters.command == 
                    "xcrun simctl privacy \(uuid.uuidString) grant photos-add sdsdsds")
            })
        }
    }

    @Test("Grant Permission Clone")
    func grantPermissionClone() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            app.shell = shellSpy
            let uuid = UUID()

            // When
            let body = PermissionRequestBody(
                permission: PermissionRequestBody.Permission.addPhotos,
                appBundleId: "sdsdsds",
                simulatorUDID: uuid,
                isClone: true
            )
            try await app.testing().test(.POST, "/permission/grant", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(response.status == .noContent)
                #expect(shellSpy.invokedRunCommandCount == 1)
                #expect(shellSpy.invokedRunCommandParameters.command == 
                    "xcrun simctl --set testing privacy \(uuid.uuidString) grant photos-add sdsdsds")
            })
        }
    }

    @Test("Revoke Permission Non Clone")
    func revokePermissionNonClone() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            app.shell = shellSpy
            let uuid = UUID()

            // When
            let body = PermissionRequestBody(
                permission: PermissionRequestBody.Permission.addPhotos,
                appBundleId: "sdsdsds",
                simulatorUDID: uuid,
                isClone: false
            )
            try await app.testing().test(.POST, "/permission/revoke", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(response.status == .noContent)
                #expect(shellSpy.invokedRunCommandCount == 1)
                #expect(shellSpy.invokedRunCommandParameters.command == 
                    "xcrun simctl privacy \(uuid.uuidString) revoke photos-add sdsdsds")
            })
        }
    }

    @Test("Grant Permission Returns Error Status When simctl Fails")
    func grantPermissionReturnsErrorStatusWhenSimctlFails() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            shellSpy.stubbedRunError = Shell.Error.commandFailed(
                command: "xcrun simctl privacy",
                exitCode: 1,
                stderr: "Invalid device: booted"
            )
            app.shell = shellSpy
            let body = PermissionRequestBody(
                permission: PermissionRequestBody.Permission.addPhotos,
                appBundleId: "sdsdsds",
                isClone: false
            )

            // When
            try await app.testing().test(.POST, "/permission/grant", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async throws in
                // Then
                #expect(response.status == .internalServerError)
                let error = try response.content.decode(ErrorBody.self)
                #expect(error.reason.contains("Invalid device: booted"))
                #expect(shellSpy.invokedRunCommandCount == 1)
            })
        }
    }

    @Test("Revoke Permission Returns Error Status When simctl Fails")
    func revokePermissionReturnsErrorStatusWhenSimctlFails() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            shellSpy.stubbedRunError = Shell.Error.commandFailed(
                command: "xcrun simctl privacy",
                exitCode: 1,
                stderr: "Invalid device: booted"
            )
            app.shell = shellSpy
            let body = PermissionRequestBody(
                permission: PermissionRequestBody.Permission.addPhotos,
                appBundleId: "sdsdsds",
                isClone: false
            )

            // When
            try await app.testing().test(.POST, "/permission/revoke", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async throws in
                // Then
                #expect(response.status == .internalServerError)
                let error = try response.content.decode(ErrorBody.self)
                #expect(error.reason.contains("Invalid device: booted"))
                #expect(shellSpy.invokedRunCommandCount == 1)
            })
        }
    }

    @Test("Revoke Permission Clone")
    func revokePermissionClone() async throws {
        try await withApp(configure: configure) { app in
            // Given
            let shellSpy = ShellableSpy()
            app.shell = shellSpy
            let uuid = UUID()

            // When
            let body = PermissionRequestBody(
                permission: PermissionRequestBody.Permission.addPhotos,
                appBundleId: "sdsdsds",
                simulatorUDID: uuid,
                isClone: true
            )
            try await app.testing().test(.POST, "/permission/revoke", beforeRequest: { request in
                try request.content.encode(body, as: .json)
            }, afterResponse: { response async in
                // Then
                #expect(response.status == .noContent)
                #expect(shellSpy.invokedRunCommandCount == 1)
                #expect(shellSpy.invokedRunCommandParameters.command == 
                    "xcrun simctl --set testing privacy \(uuid.uuidString) revoke photos-add sdsdsds")
            })
        }
    }
}
