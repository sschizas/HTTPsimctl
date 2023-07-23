//
//  OpenURLRequestBody.swift
//
//  Created by Stavros Schizas on 27/10/22.
//

import Vapor

/// A request body for opening a URL on a simulator.
/// - Note: The `simulatorUDID` property is optional, as it is not required for all requests.
struct OpenURLRequestBody: Content, SimulatorID {
  /// The URL to open.
  let urlToOpen: URL

  /// The UUID of the simulator to open the URL on.
  var simulatorUDID: UUID?
}

extension OpenURLRequestBody: Validatable {
  /// Adds validations for the `urlToOpen` and `simulatorUDID` properties.
  static func validations(_ validations: inout Vapor.Validations) {
    validations.add("urlToOpen", as: String.self, is: !.empty && .url)
    validations.add("simulatorUDID", as: UUID?.self, is: .nil || !.nil, required: false)
  }
}
