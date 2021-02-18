import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)

app.http.server.configuration.address = BindAddress.hostname("0.0.0.0", port: 80)
defer { app.shutdown() }
try configure(app)
try app.run()
