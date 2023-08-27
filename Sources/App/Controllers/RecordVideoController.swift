//
//  RecordVideoController.swift
//
//  Created by Stavros Schizas on 16/3/23.
//

import Vapor

struct RecordVideoController: RouteCollection {
    let fileExtension = "mp4"

    func boot(routes: Vapor.RoutesBuilder) throws {
        let routesGroup = routes.grouped("record-video")
        routesGroup.post("start", use: recordVideo)
        routesGroup.post("stop", use: stopRecordingVideo)
        routesGroup.delete(use: deleteRecordedVideo)
    }
    
    // MARK: Handlers
    private func recordVideo(req: Request) async throws -> RecordVideoResponse {
        try RecordVideoRequestBody.validate(content: req)
        let body = try req.content.decode(RecordVideoRequestBody.self)
        do {
            req.application.logger.info("Start recording video with filename: \(body.fileName)")
            let pid = try req.application.shell.runCommandWithReturn("xcrun simctl --set testing io \(body.udid) recordVideo --codec=h264 --force \(body.fileName).\(self.fileExtension) >/dev/null 2>&1 & echo $!")
            return .init(pid: Int(pid)!)
        } catch {
            req.application.logger.report(error: error)
            throw error
        }
    }

    private func stopRecordingVideo(req: Request) async throws -> StopRecordingVideoResponse {
        try StopRecordingVideoRequestBody.validate(content: req)
        let body = try req.content.decode(StopRecordingVideoRequestBody.self)
        do {
            req.application.logger.info("Stop recording video with filename: \(body.fileName)")
            req.application.shell.run("kill -s SIGINT \(body.pid)")
            checkProcessStatus(pid: Int32(body.pid), shell: req.application.shell)
            let filepath = try req.application.shell.runCommandWithReturn("realpath \(body.fileName).\(self.fileExtension)").trimmingCharacters(in: .whitespacesAndNewlines)
            return .init(filePath: filepath)
        } catch {
            req.application.logger.report(error: error)
            throw error
        }
    }

    private func deleteRecordedVideo(req: Request) async throws -> Response {
        try StopRecordingVideoRequestBody.validate(content: req)
        let body = try req.content.decode(StopRecordingVideoRequestBody.self)
        req.application.logger.info("Stop recording video with filename: \(body.fileName)")
        req.application.shell.run("kill -s SIGINT \(body.pid)")
        checkProcessStatus(pid: Int32(body.pid), shell: req.application.shell)
        req.application.shell.run("rm \(body.fileName).\(self.fileExtension)")
        return .init(status: .ok)
    }
    
    private func checkProcessStatus(pid: Int32, shell: any Shellable) {
        var isRunning = true
        while isRunning {
            isRunning = shell.isProcessRunning(pid: pid)
            sleep(1)
        }
    }
}
