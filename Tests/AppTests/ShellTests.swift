//
//  ShellTests.swift
//
//  Exercises the real `Shell` (no spy) against harmless local commands.
//

@testable import App
import Foundation
import Testing

@Suite("Shell Tests")
struct ShellTests {
    let shell = Shell()

    @Test("Returns trimmed standard output")
    func returnsTrimmedStandardOutput() async throws {
        let output = try await shell.runCommandWithReturn("echo hello")
        #expect(output == "hello")
    }

    @Test("Run waits for the command to finish")
    func runWaitsForCommandToFinish() async throws {
        let marker = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .path
        defer { try? FileManager.default.removeItem(atPath: marker) }

        try await shell.run("sleep 0.3 && touch \(marker)")

        #expect(FileManager.default.fileExists(atPath: marker))
    }

    @Test("Run throws commandFailed with the exit code on a non-zero exit")
    func runThrowsCommandFailedWithExitCode() async {
        await #expect(throws: Shell.Error.self) {
            try await shell.run("exit 3")
        }

        do {
            try await shell.run("exit 3")
            Issue.record("Expected the command to throw")
        } catch let Shell.Error.commandFailed(command, exitCode, _) {
            #expect(command == "exit 3")
            #expect(exitCode == 3)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test("Failure carries stderr and maps to an error status")
    func failureCarriesStandardError() async throws {
        do {
            _ = try await shell.runCommandWithReturn("echo boom >&2; exit 1")
            Issue.record("Expected the command to throw")
        } catch let error as Shell.Error {
            guard case .commandFailed(_, _, let stderr) = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(stderr == "boom")
            #expect(error.status == .internalServerError)
            #expect(error.reason.contains("boom"))
        }
    }

    @Test("A command that outruns the timeout is terminated and reported as timedOut")
    func timesOutAndTerminates() async throws {
        let shell = Shell(timeout: .milliseconds(200))
        let start = ContinuousClock.now

        do {
            try await shell.run("sleep 5")
            Issue.record("Expected the command to time out")
        } catch let error as Shell.Error {
            guard case .timedOut(let command) = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(command == "sleep 5")
            #expect(error.status == .gatewayTimeout)
        }

        #expect(ContinuousClock.now - start < .seconds(4))
    }

    @Test("Concurrent commands do not serialise behind each other")
    func concurrentCommandsRunInParallel() async throws {
        let start = ContinuousClock.now
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<8 {
                group.addTask { try await Shell().run("sleep 0.5") }
            }
            try await group.waitForAll()
        }
        // 8 x 0.5s run serially would take 4s.
        #expect(ContinuousClock.now - start < .seconds(2.5))
    }

    @Test("Background pattern used for video recording returns the PID promptly")
    func backgroundPatternReturnsPID() async throws {
        let start = ContinuousClock.now
        let pid = try await shell.runCommandWithReturn("sleep 30 >/dev/null 2>&1 & echo $!")
        let elapsed = ContinuousClock.now - start
        defer { kill(pid_t(pid) ?? 0, SIGKILL) }

        #expect(Int(pid) != nil)
        #expect(elapsed < .seconds(5))
        #expect(shell.isProcessRunning(pid: pid) == .running)
    }

    @Test("isProcessRunning reports terminated for a dead PID")
    func isProcessRunningReportsTerminated() async throws {
        let pid = try await shell.runCommandWithReturn("sleep 30 >/dev/null 2>&1 & echo $!")
        kill(pid_t(pid) ?? 0, SIGKILL)

        // Wait briefly for the kernel to reap it.
        var status = shell.isProcessRunning(pid: pid)
        for _ in 0..<20 where status == .running {
            try await Task.sleep(for: .milliseconds(50))
            status = shell.isProcessRunning(pid: pid)
        }
        #expect(status == .terminated)
    }

    @Test("isProcessRunning rejects invalid PIDs")
    func isProcessRunningRejectsInvalidPIDs() {
        #expect(shell.isProcessRunning(pid: "not-a-pid") == .error)
        #expect(shell.isProcessRunning(pid: "0") == .error)
        #expect(shell.isProcessRunning(pid: "-1") == .error)
    }
}
