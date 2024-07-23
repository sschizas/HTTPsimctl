//
//  RecordVideoController.swift
//
//  Created by Stavros Schizas on 16/3/23.
//

import Vapor

struct RecordVideoController: RouteCollection {
    enum RecordVideoError {
        case pidNotFound
    }
    
    let fileExtension = "mp4"
    var pids: [String: String] = [:]
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        let routesGroup = routes.grouped("record-video")
        routesGroup.post("start", use: recordVideo)
        routesGroup.post("stop", use: stopRecordingVideo)
        routesGroup.delete(use: deleteRecordedVideo)
    }
    
    // MARK: Handlers
    private func recordVideo(req: Request) async throws -> Response {
        try RecordVideoRequestBody.validate(content: req)
        let body = try req.content.decode(RecordVideoRequestBody.self)
        do {
            let testingFlag = body.isClone ? "--set testing " : ""
            req.application.logger.info("Start recording video with filename: \(body.fileName)")
            let pid = try req.application.shell.runCommandWithReturn("xcrun simctl \(testingFlag)io \(body.udid) recordVideo --codec=h264 --force \(body.fileName).\(self.fileExtension) >/dev/null 2>&1 & echo $!")
            try await req.cache.set(body.fileName, to: pid)
            return Response(status: .ok)
        } catch {
            req.application.logger.report(error: error)
            throw error
        }
    }
    
    private func stopRecordingVideo(req: Request) async throws -> StopRecordingVideoResponse {
        try StopRecordingVideoRequestBody.validate(content: req)
        let body = try req.content.decode(StopRecordingVideoRequestBody.self)
        do {
            guard let pid: String = try await req.cache.get(body.fileName) else {
                throw Abort(HTTPResponseStatus.internalServerError, reason: "PID for \(body.fileName) not found in cache.")
            }
            try await self.terminatePID(req, body, pid)
            let filepath = try req.application.shell.runCommandWithReturn("realpath \(body.fileName).\(self.fileExtension)").trimmingCharacters(in: .whitespacesAndNewlines)
            return StopRecordingVideoResponse(filePath: filepath)
        } catch {
            req.application.logger.report(error: error)
            throw error
        }
    }
    
    private func deleteRecordedVideo(req: Request) async throws -> Response {
        try StopRecordingVideoRequestBody.validate(content: req)
        let body = try req.content.decode(StopRecordingVideoRequestBody.self)
        guard let pid: String = try await req.cache.get(body.fileName) else {
            throw Abort(HTTPResponseStatus.internalServerError, reason: "PID for \(body.fileName) not found in cache.")
        }
        try await self.terminatePID(req, body, pid)
        req.application.logger.info("Delete video with filename: \(body.fileName)")
        try req.application.shell.run("rm \(body.fileName).\(self.fileExtension)")
        return Response(status: .ok)
    }
    
    private func terminatePID(_ req: Request, _ body: StopRecordingVideoRequestBody, _ pid: String) async throws {
        req.application.logger.info("Stop recording video with filename: \(body.fileName)")
        try req.application.shell.run("kill -s SIGINT \(pid)")
        
        var status: ProcessStatus = .running
        while status == .running {
            status = req.application.shell.isProcessRunning(pid: pid)
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        switch status {
        case .terminated:
            req.application.logger.info("Process with PID \(pid) has terminated.")

        case .error:
            req.application.logger.error("Error checking the process status for PID \(pid).")

        case .running:
            break
        }
    }
}
