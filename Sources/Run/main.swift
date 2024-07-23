import App
import Vapor

var env = try Environment.detect()
let app = Application(env)

try LoggingSystem.bootstrap(from: &env)

app.servers.use(.http)
app.http.server.configuration.port = 9_000
// Enable HTTP response compression.
app.http.server.configuration.responseCompression = .enabled(initialByteBufferCapacity: 1_024)
// Enable HTTP request decompression.
app.http.server.configuration.requestDecompression = .enabled
app.commands.use(VersionCommand(), as: "version")

defer { app.shutdown() }
try configure(app)
try app.run()
