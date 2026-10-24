//
//  ErrorBody.swift
//
//  The JSON body Vapor's ErrorMiddleware produces for an `AbortError`.
//

import Vapor

struct ErrorBody: Content {
    let error: Bool
    let reason: String
}
