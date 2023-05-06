//
//  StopRecordingVideoRequestBody.swift
//
//  Created by Stavros Schizas on 16/3/23.
//

import Vapor

/// A request body for stopping a video recording.
///
/// Use this struct to decode the request body of a `POST` request to stop a video recording.
struct StopRecordingVideoRequestBody: Content {

    /// The process ID of the recording to stop.
    let pid: Int

    /// The name of the file to save the recording to.
    let fileName: String
}

extension StopRecordingVideoRequestBody: Validatable {

    /// Adds validations for the `pid` and `fileName` properties.
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("pid", as: Int.self, is: .valid)
        validations.add("fileName", as: String.self, is: .count(3...) && .characterSet(.alphanumerics))
    }
}

