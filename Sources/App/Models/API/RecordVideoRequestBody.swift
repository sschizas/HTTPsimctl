//
//  RecordVideoRequestBody.swift
//
//  Created by Stavros Schizas on 16/3/23.
//

import Vapor

struct RecordVideoRequestBody: Content, SimulatorID {
    let fileName: String
    var simulatorUDID: UUID?
}

extension RecordVideoRequestBody: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("fileName", as: String.self, is: .count(3...) && .characterSet(.alphanumerics))
        validations.add("simulatorUDID", as: UUID?.self, is: .nil || !.nil, required: false)
    }
}
