//
//  OpenURLController.swift
//
//  Created by Stavros Schizas on 27/10/22.
//

import Vapor

struct SendPNController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let routesGroup = routes.grouped("send-pn")
        routesGroup.post(use: sendPN)
    }
}

// MARK: Handlers
private func sendPN(req: Request) async throws -> Response {
    //    let body = try req.content.decode(OpenURLRequestBody.self)
    //    try Shell().safeShell("xcrun simctl openurl booted \(body.urlToOpen)")
    return Response(status: .noContent)
}
