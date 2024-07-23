//
//  APNSRequestBody.swift
//
//  Created by Stavros Schizas on 14/7/24.
//

import Vapor

/// A request body for opening a APNS on a simulator.
/// - Note: The `simulatorUDID` property is optional, as it is not required for all requests.
struct APNSRequestBody: Content, SimulatorID {
    /// The APNS to open..
    let apns: String
    
    /// The UUID of the simulator to open the URL on.
    var simulatorUDID: UUID?
    
    /// A boolean value indicating whether the simulator is a clone.
    let isClone: Bool
    
    let appBundleId: String
}

extension APNSRequestBody: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("apns", as: String.self, is: !.empty, required: true)
        validations.add("simulatorUDID", as: UUID?.self, is: .nil || !.nil, required: false)
        validations.add("isClone", as: Bool.self)
        validations.add("appBundleId", as: String.self, is: !.empty, required: true)
    }
}
