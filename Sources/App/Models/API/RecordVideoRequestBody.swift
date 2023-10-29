//
//  RecordVideoRequestBody.swift
//
//  Created by Stavros Schizas on 16/3/23.
//

import Vapor

/// A request body for recording a video.
/// - Note: The `fileName` property is required, while `simulatorUDID` is optional.
/// - Warning: The `fileName` property must be at least 3 characters long and contain only alphanumeric characters.
struct RecordVideoRequestBody: Content, SimulatorID {
    /// The name of the video file to be recorded.
    let fileName: String
    
    /// The UUID of the simulator to record the video from.
    var simulatorUDID: UUID?
    
    /// A boolean value indicating whether the simulator is a clone.
    var isClone: Bool
}

extension RecordVideoRequestBody: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("fileName", as: String.self, is: .count(3...) && .characterSet(.alphanumerics))
        validations.add("simulatorUDID", as: UUID?.self, is: .nil || !.nil, required: false)
        validations.add("isClone", as: Bool.self)
    }
}
