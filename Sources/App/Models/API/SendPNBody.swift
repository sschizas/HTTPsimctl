//
//  SendPNBody.swift
//
//  Created by Stavros Schizas on 27/10/22.
//

import Vapor

/// The body of a push notification request.
///
/// Use this struct to send a push notification to a user.
/// - Note: This struct conforms to `Content`, so it can be used as the request body in a Vapor route.
struct SendPNBody: Content {
  // This struct is intentionally empty, as the push notification payload is sent in the request headers.
}
