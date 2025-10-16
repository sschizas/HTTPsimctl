import Vapor
import Logging

@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)

        let app = try await Application.make(env)
        app.servers.use(.http)
        app.http.server.configuration.port = 9_000
        // Enable HTTP response compression.
        app.http.server.configuration.responseCompression = .enabled(initialByteBufferCapacity: 1_024)
        // Enable HTTP request decompression.
        app.http.server.configuration.requestDecompression = .enabled
        app.commands.use(VersionCommand(), as: "version")

        do {
            try await configure(app)
            try await app.execute()
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
}

// This attempts to install NIO as the Swift Concurrency global executor.
// You can enable it if you'd like to reduce the amount of context switching between NIO and Swift Concurrency.
// Note: this has caused issues with some libraries that use `.wait()` and cleanly shutting down.
// If enabled, you should be careful about calling async functions before this point as it can cause assertion failures.
// let executorTakeoverSuccess = NIOSingletons.unsafeTryInstallSingletonPosixEventLoopGroupAsConcurrencyGlobalExecutor()
// app.logger.debug("Tried to install SwiftNIO's EventLoopGroup as Swift's global concurrency executor", metadata: ["success": .stringConvertible(executorTakeoverSuccess)])
