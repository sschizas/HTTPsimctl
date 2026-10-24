//
//  Shell.swift
//
//
//  Created by Stavros Schizas on 27/10/22.
//

import Foundation
import Subprocess
import Vapor

/// A protocol defining methods to interact with the shell or command-line interface.
public protocol Shellable: Sendable {
    /// Runs a shell command and returns after it exits.
    ///
    /// Suspends (rather than blocks a thread) while the command runs.
    /// - Parameter command: The shell command to execute.
    /// - Throws: `Shell.Error` on a non-zero exit or a timeout.
    func run(_ command: String) async throws

    /// Runs a shell command and returns its standard output after it exits.
    ///
    /// Suspends (rather than blocks a thread) while the command runs.
    /// - Parameter command: The shell command to execute.
    /// - Returns: The trimmed standard output of the command.
    /// - Throws: `Shell.Error` on a non-zero exit or a timeout.
    @discardableResult
    func runCommandWithReturn(_ command: String) async throws -> String

    /// Checks if a process with the given process ID (PID) is currently running.
    ///
    /// - Parameter pid: The process ID (PID) to check.
    /// - Returns: `.running` if the process exists, `.terminated` if it doesn't, `.error` if `pid` is invalid.
    func isProcessRunning(pid: String) -> ProcessStatus
}

public enum ProcessStatus {
    case running
    case terminated
    case error
}

struct ShellKey: StorageKey {
    typealias Value = any Shellable
}

final class Shell: Shellable {
    typealias Value = Shell

    enum Error: Swift.Error {
        /// The command ran but did not exit with status 0. Signal deaths are reported as `128 + signal`.
        case commandFailed(command: String, exitCode: Int32, stderr: String)
        /// The command did not finish within the timeout and was terminated.
        case timedOut(command: String)
    }

    /// Upper bound for captured stdout / stderr. `simctl` output is tiny; this only guards against runaway output.
    private static let outputLimit = 1_048_576

    private let timeout: Duration

    init(timeout: Duration = .seconds(60)) {
        self.timeout = timeout
    }

    func run(_ command: String) async throws {
        _ = try await self.execute(command)
    }

    @discardableResult
    func runCommandWithReturn(_ command: String) async throws -> String {
        try await self.execute(command)
    }

    func isProcessRunning(pid: String) -> ProcessStatus {
        guard let pid = pid_t(pid), pid > 0 else { return .error }
        // kill(pid, 0) only checks that the process exists: no child process, nothing to wait for.
        if kill(pid, 0) == 0 { return .running }
        // EPERM means it exists but belongs to someone else.
        return errno == EPERM ? .running : .terminated
    }

    // MARK: Private

    private enum Outcome: Sendable {
        case finished(String)
        case timedOut
    }

    /// Runs `command`, racing it against the timeout.
    ///
    /// Cancelling the spawning task makes Subprocess tear the process down (SIGTERM, then SIGKILL),
    /// so a hung `simctl` is cleaned up rather than leaked.
    private func execute(_ command: String) async throws -> String {
        let timeout = self.timeout
        return try await withThrowingTaskGroup(of: Outcome.self) { group in
            group.addTask { .finished(try await Self.spawn(command)) }
            group.addTask {
                try await Task.sleep(for: timeout)
                return .timedOut
            }

            if case .finished(let output)? = try await group.next() {
                group.cancelAll()
                return output
            }

            // Timed out: cancel the spawn and let its teardown complete before reporting.
            group.cancelAll()
            _ = try? await group.next()
            throw Error.timedOut(command: command)
        }
    }

    /// Runs `command` through `/bin/bash -c` and suspends until it exits.
    private static func spawn(_ command: String) async throws -> String {
        var platformOptions = PlatformOptions()
        platformOptions.teardownSequence = [.gracefulShutDown(allowedDurationToNextStep: .seconds(2))]

        let result = try await Subprocess.run(
            .path("/bin/bash"),
            arguments: ["-c", command],
            platformOptions: platformOptions,
            output: .string(limit: Self.outputLimit),
            error: .string(limit: Self.outputLimit)
        )

        let exitCode: Int32
        switch result.terminationStatus {
        case .exited(let code):
            exitCode = code
        case .signaled(let signal):
            exitCode = 128 + signal
        }

        guard exitCode == 0 else {
            throw Error.commandFailed(
                command: command,
                exitCode: exitCode,
                stderr: result.standardError.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
        return result.standardOutput.trimmingCharacters(in: .newlines)
    }
}

extension Application {
    var shell: any Shellable {
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
        case .commandFailed:
            return .internalServerError
        case .timedOut:
            return .gatewayTimeout
        }
    }

    var reason: String {
        switch self {
        case let .commandFailed(command, exitCode, stderr):
            return "`\(command)` exited with \(exitCode): \(stderr)"
        case let .timedOut(command):
            return "`\(command)` did not finish in time and was terminated."
        }
    }
}
