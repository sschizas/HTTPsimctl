//
//  ShellableSpy.swift
//
//  Created by Stavros Schizas on 16/3/23.
//

import App

final class ShellableSpy: Shellable, @unchecked Sendable {
    var invokedRunCommand = false
    var invokedRunCommandCount = 0
    var invokedRunCommandParameters: (command: String, Void)!
    var invokedRunCommandParametersList = [(command: String, Void)]()
    var stubbedRunError: Error?
    func run(_ command: String) async throws {
        self.invokedRunCommand = true
        self.invokedRunCommandCount += 1
        self.invokedRunCommandParameters = (command, ())
        self.invokedRunCommandParametersList.append((command, ()))
        if let stubbedRunError {
            throw stubbedRunError
        }
    }

    var invokedRunCommandWithReturn = false
    var invokedRunCommandWithReturnCount = 0
    var invokedRunCommandWithReturnParameters: (command: String, Void)!
    var invokedRunCommandWithReturnParamsList = [(command: String, Void)]()
    var stubbedRunCommandWithReturn: String! = ""
    var stubbedRunCommandWithReturnError: Error?
    func runCommandWithReturn(_ command: String) async throws -> String {
        self.invokedRunCommandWithReturn = true
        self.invokedRunCommandWithReturnCount += 1
        self.invokedRunCommandWithReturnParameters = (command, ())
        self.invokedRunCommandWithReturnParamsList.append((command, ()))
        if let stubbedRunCommandWithReturnError {
            throw stubbedRunCommandWithReturnError
        }
        return self.stubbedRunCommandWithReturn
    }

    var invokedIsProcessRunning = false
    var invokedIsProcessRunningCount = 0
    var invokedIsProcessRunningParameters: (pid: String, Void)!
    var stubbedIsProcessRunning = ProcessStatus.running
    func isProcessRunning(pid: String) -> ProcessStatus {
        self.invokedIsProcessRunning = true
        self.invokedIsProcessRunningCount += 1
        self.invokedIsProcessRunningParameters = (pid, ())
        return self.stubbedIsProcessRunning
    }
}
