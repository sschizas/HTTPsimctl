//
//  SimulatorID.swift
//
//  Created by Stavros Schizas on 14/3/23.
//

import Vapor

/// A protocol for objects that have a simulator UUID.
///
/// Conforming types can use this protocol to get a `simulatorUDID` property.
/// - Note: The `simulatorUDID` property is optional, so conforming types can choose to not implement it.
public protocol SimulatorID {
    /// The UUID of the simulator.
    var simulatorUDID: UUID? { get set }
}

extension SimulatorID {
    ///  A computed property that returns the UUID of the simulator, or "booted" if the UUID is nil.
    ///
    /// - Returns: A string representation of the simulator UUID, or "booted" if the UUID is nil.
    var udid: String {
        self.simulatorUDID?.uuidString ?? "booted"
    }
}
