//
//  RecordVideoRequestBody.swift
//
//  Created by Stavros Schizas on 16/3/23.
//

import Vapor

struct StopRecordingVideoRequestBody: Content {
    let pid: Int
    let fileName: String
}

extension StopRecordingVideoRequestBody: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("pid", as: Int.self, is: .valid)
        validations.add("fileName", as: String.self, is: .count(3...) && .characterSet(.alphanumerics))
    }
}
