//
//  APNSController.swift
//
//  Created by Stavros Schizas on 12/7/24.
//

import Vapor

struct APNSController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let routesGroup = routes.grouped("apns")
        routesGroup.post(use: openURL)
    }

    // MARK: Handlers
    private func openURL(req: Request) async throws -> Response {
        try APNSRequestBody.validate(content: req)
        let body = try req.content.decode(APNSRequestBody.self)
        req.application.logger.info("Sending APNS: \(body.apns)")
        let testingFlag = body.isClone ? "--set testing " : ""

        // Create a temporary file to store the JSON payload
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("json")

        // Write the JSON payload to the temporary file, and remove it on every exit path.
        try body.apns.unescapedJSONString().write(to: tempFileURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempFileURL) }
        req.application.logger.info("Temporary file created at: \(tempFileURL.path)")

        do {
            try await req.application.shell.runCommandWithReturn(
                "xcrun simctl \(testingFlag)push \(body.udid) \(body.appBundleId) \(tempFileURL.path)"
            )
        } catch {
            // Surface simctl's own error to the client instead of a generic message.
            req.application.logger.report(error: error)
            throw error
        }
        return Response(status: .noContent)
    }
}

import Foundation

extension String {
    func unescapedJSONString() -> String {
        guard let jsonData = self.data(using: .utf8) else {
            print("Error: Cannot convert string to UTF-8 data.")
            return self
        }

        do {
            // Deserialize the JSON string into an object
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
            // Serialize the object back into JSON data with pretty printing
            let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            // Convert the JSON data back into a string
            if let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
                return prettyPrintedString
            } else {
                print("Error: Cannot convert data to UTF-8 string.")
                return self
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return self
        }
    }
}
