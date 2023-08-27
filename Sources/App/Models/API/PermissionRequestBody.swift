//
//  PermissionRequestBody.swift
//
//  Created by Stavros Schizas on 27/8/23.
//

import Vapor

struct PermissionRequestBody: Content, SimulatorID {
    enum Permission: String, Codable, CaseIterable {
        case all
        case calendar
        case contactsLimited = "contacts-limited"
        case location
        case locationAlways = "location-always"
        case addPhotos = "photos-add"
        case photos
        case mediaLibrary = "media-library"
        case microphone
        case motion
        case reminders
        case siri
    }
    
    let permission: Permission
    
    let appBundleId: String
    
    /// The UUID of the simulator to record the video from.
    var simulatorUDID: UUID?
}

extension PermissionRequestBody: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        // Validate the permission property
        validations.add(
            "permission",
            as: String.self,
            is: .in(PermissionRequestBody.Permission.allCases.map { $0.rawValue }),
            required: true
        )
        
        // Validate appBundleId property
        validations.add("appBundleId", as: String.self, is: !.empty, required: true)
        
        // Validate the simulatorUDID property
        validations.add("simulatorUDID", as: UUID?.self, is: .nil || !.nil, required: false)
    }
}
