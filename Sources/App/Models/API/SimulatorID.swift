//
//  File.swift
//  
//
//  Created by Stavros Schizas on 14/3/23.
//

import Foundation

public protocol SimulatorID {
    var simulatorUDID: UUID? { get set }
}

extension SimulatorID {
    var udid: String {
        return self.simulatorUDID?.uuidString ?? "booted"
    }
}
