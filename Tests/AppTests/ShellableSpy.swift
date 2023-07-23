//
//  ShellableSpy.swift
//
//  Created by Stavros Schizas on 16/3/23.
//

import App

final class ShellableSpy: Shellable {
    var invokedRunCommand = false
    var invokedRunCommandCount = 0
    var invokedRunCommandParameters: (command: String, Void)!
    var invokedRunCommandParametersList = [(command: String, Void)]()
    func run(_ command: String) {
        self.invokedRunCommand = true
        self.invokedRunCommandCount += 1
        self.invokedRunCommandParameters = (command, ())
        self.invokedRunCommandParametersList.append((command, ()))
    }
    
    var invokedRunCommandWithReturn = false
    var invokedRunCommandWithReturnCount = 0
    var invokedRunCommandWithReturnParameters: (command: String, Void)!
    var invokedRunCommandWithReturnParametersList = [(command: String, Void)]()
    var stubbedRunCommandWithReturn: String! = ""
    func runCommandWithReturn(_ command: String) throws -> String {
        self.invokedRunCommandWithReturn = true
        self.invokedRunCommandWithReturnCount += 1
        self.invokedRunCommandWithReturnParameters = (command, ())
        self.invokedRunCommandWithReturnParametersList.append((command, ()))
        return self.stubbedRunCommandWithReturn
    }
    
    var invokedIsProcessRunning = false
    var invokedIsProcessRunningCount = 0
    var invokedIsProcessRunningParameters: (pid: Int32, Void)!
    var stubbedIsProcessRunning = false
    func isProcessRunning(pid: Int32) -> Bool {
        self.invokedIsProcessRunning = true
        self.invokedIsProcessRunningCount += 1
        self.invokedIsProcessRunningParameters = (pid, ())
        return self.stubbedIsProcessRunning
    }
}
