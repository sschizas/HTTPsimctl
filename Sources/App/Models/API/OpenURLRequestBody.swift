//
//  OpenURLRequestBody.swift
//
//  Created by Stavros Schizas on 27/10/22.
//

import Vapor

struct OpenURLRequestBody: Content, SimulatorID {
    let urlToOpen: URL
    var simulatorUDID: UUID?
}

extension OpenURLRequestBody: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("urlToOpen", as: String.self, is: !.empty && .url)
        validations.add("simulatorUDID", as: UUID?.self, is: .nil || !.nil, required: false)
    }
}
