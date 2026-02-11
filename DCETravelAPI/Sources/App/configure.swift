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
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Configure JSON encoding/decoding with ISO8601 dates
    let encoder = JSONEncoder.apiEncoder
    let decoder = JSONDecoder.apiDecoder
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    // Set port
    app.http.server.configuration.port = 8080

    // Register routes
    try routes(app)
}
