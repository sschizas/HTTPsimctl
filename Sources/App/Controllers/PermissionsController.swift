//
//  PermissionsController.swift
//
//  Created by Stavros Schizas on 27/8/23.
//

import Vapor

struct PermissionsController: RouteCollection {
    enum PermissionAction: String {
        case grant
        case revoke
    }

    func boot(routes: Vapor.RoutesBuilder) throws {
        let routesGroup = routes.grouped("permission")
        routesGroup.post("grant", use: grantPermission)
        routesGroup.post("revoke", use: revokePermission)
    }

    // MARK: Handlers
    private func grantPermission(req: Request) async throws -> Response {
        try await self.permissionHandler(req: req, action: PermissionAction.grant)
    }

    private func revokePermission(req: Request) async throws -> Response {
        try await self.permissionHandler(req: req, action: PermissionAction.revoke)
    }

    private func permissionHandler(req: Request, action: PermissionAction) async throws -> Response {
        try PermissionRequestBody.validate(content: req)
        let body = try req.content.decode(PermissionRequestBody.self)
        req.application.logger.info("\(action.rawValue) permission: \(body.permission.rawValue)")
        req.application.shell.run(
            "xcrun simctl --set testing privacy \(body.udid) \(action.rawValue) \(body.permission.rawValue) \(body.appBundleId)"
        )
        return Response(status: .noContent)
    }
}
