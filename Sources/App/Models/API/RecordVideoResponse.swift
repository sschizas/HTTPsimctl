//
//  RecordVideoRequestBody.swift
//
//  Created by Stavros Schizas on 16/3/23.
//

import Vapor

/// A response from the server after a video recording has been requested
/// - `pid`: The process ID of the recording.
struct RecordVideoResponse: Content {
    let pid: Int
}

extension RecordVideoResponse: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("pid", as: Int.self)
    }
}
