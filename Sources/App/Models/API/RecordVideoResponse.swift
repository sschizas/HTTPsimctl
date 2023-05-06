//
//  RecordVideoRequestBody.swift
//
//  Created by Stavros Schizas on 16/3/23.
//

import Vapor

struct RecordVideoResponse: Content {
    let pid: Int
}

extension RecordVideoResponse: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("pid", as: Int.self)
    }
}
