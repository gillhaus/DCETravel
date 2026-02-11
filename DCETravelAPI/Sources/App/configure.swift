import Vapor

func configure(_ app: Application) throws {
    // CORS middleware
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .PATCH, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)

    // Serve files from Public directory (for Swagger docs, etc.)
    // Use explicit path relative to binary for production Docker deployments
    let publicDir: String
    if FileManager.default.fileExists(atPath: app.directory.publicDirectory + "docs") {
        publicDir = app.directory.publicDirectory
    } else {
        publicDir = "/app/Public/"
    }
    app.middleware.use(FileMiddleware(publicDirectory: publicDir))

    // Configure JSON encoding/decoding with ISO8601 dates
    let encoder = JSONEncoder.apiEncoder
    let decoder = JSONDecoder.apiDecoder
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    // Set port (Railway provides PORT env var)
    let port = Environment.get("PORT").flatMap(Int.init) ?? 8080
    app.http.server.configuration.port = port
    app.http.server.configuration.hostname = "0.0.0.0"

    // Register routes
    try routes(app)
}
