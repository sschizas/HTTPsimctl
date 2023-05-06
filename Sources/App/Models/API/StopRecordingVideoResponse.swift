//
//  RecordVideoRequestBody.swift
//
//  Created by Stavros Schizas on 16/3/23.
//

import Vapor

struct StopRecordingVideoResponse: Content {
    let filePath: String
}

extension StopRecordingVideoResponse: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("filePath", as: String.self)
    }
}
