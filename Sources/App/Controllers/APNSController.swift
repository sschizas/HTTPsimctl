//
//  APNSController.swift
//
//  Created by Stavros Schizas on 12/7/24.
//

import Vapor

struct APNSController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
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
        
        do {
            // Write the JSON payload to the temporary file
            try body.apns.unescapedJSONString().write(to: tempFileURL, atomically: true, encoding: .utf8)
            
            // Log the file path
            req.application.logger.info("Temporary file created at: \(tempFileURL.path)")
            
            // Construct the command to use the temporary file
            let command = "/usr/bin/xcrun"
            let arguments = ["simctl", testingFlag + "push", "booted", body.appBundleId, tempFileURL.path]
            
            // Log the command being executed
            req.application.logger.info("Executing command: \(command) \(arguments.joined(separator: " "))")
            
            try req.application.shell.runCommandWithReturn("xcrun simctl \(testingFlag)push \(body.udid) \(body.appBundleId) \(tempFileURL.path)")
            
            // Clean up the temporary file
            try FileManager.default.removeItem(at: tempFileURL)
            
            return Response(status: .noContent)
        } catch {
            // Log the error
            req.application.logger.error("Error during openURL handler: \(error.localizedDescription)")
            throw Abort(.internalServerError, reason: "Failed to send APNS push notification")
        }
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
