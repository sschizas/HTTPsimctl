//
//  OpenURLController.swift
//
//  Created by Stavros Schizas on 27/10/22.
//

import Vapor

struct OpenURLController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let routesGroup = routes.grouped("open-url")
        routesGroup.post(use: openURL)
    }
    
    // MARK: Handlers
    private func openURL(req: Request) async throws -> Response {
        try OpenURLRequestBody.validate(content: req)
        let body = try req.content.decode(OpenURLRequestBody.self)
        req.application.logger.info("Opening url: \(body.urlToOpen)")
        req.application.shell?.run("xcrun simctl --set testing openurl \(body.udid) \"\(body.urlToOpen)\"")
        return Response(status: .noContent)
    }
}
