//
//  Shell.swift
//  
//
//  Created by Stavros Schizas on 27/10/22.
//

import Foundation
import Vapor

public protocol Shellable {
    func run(_ command: String)
    @discardableResult
    func runCommandWithReturn(_ command: String) throws -> String
    func isProcessRunning(pid: Int32) -> Bool
}

struct ShellKey: StorageKey {
    typealias Value = Shellable
}

final class Shell: Shellable {
    typealias Value = Shell
    
    enum Error: Swift.Error {
        case shellOutputFailed
    }
    
    func run(_ command: String) {
        let task = Process()
        task.arguments = ["-c", command]
        task.launchPath = "/bin/bash"
        task.launch()
    }
    
    @discardableResult
    func runCommandWithReturn(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/bash"
        
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        guard let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines) else {
            throw Error.shellOutputFailed
        }
        return output
    }
    
    func isProcessRunning(pid: Int32) -> Bool {
        let task = Process()
        task.launchPath = "/bin/ps"
        task.arguments = ["-p", "\(pid)"]
        task.standardOutput = Pipe()
        task.launch()

        task.waitUntilExit()
        return task.terminationStatus == 0
    }
}

extension Application {
    var shell: (any Shellable)! {
        get {
            self.storage[ShellKey.self, default: Shell()]
        }
        set {
            self.storage[ShellKey.self] = newValue
        }
    }
}

extension Shell.Error: AbortError {
    var description: String { reason }
    
    var status: HTTPResponseStatus {
        switch self {
        case .shellOutputFailed: return .internalServerError
        }
    }
    
    var reason: String {
        switch self {
        case .shellOutputFailed:
            return "Failed to read shell output."
        }
    }
}
