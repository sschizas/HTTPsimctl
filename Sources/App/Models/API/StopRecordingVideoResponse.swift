//
//  StopRecordingVideoResponse.swift
//
//  Created by Stavros Schizas on 16/3/23.
//

import Vapor

/// A response from the server after stopping a video recording.
///
/// The response contains the file path where the recorded video is stored.
struct StopRecordingVideoResponse: Content {

  /// The file path where the recorded video is stored.
  let filePath: String
}

extension StopRecordingVideoResponse: Validatable {

  /// Adds validation rules for the `filePath` property.
  static func validations(_ validations: inout Vapor.Validations) {
    validations.add("filePath", as: String.self)
  }
}
