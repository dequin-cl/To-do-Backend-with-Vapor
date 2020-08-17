import Fluent
import FluentPostgresDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) throws {

    app.logger.logLevel = .trace

    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.jwt.signers.use(.hs512(key: Environment.get("SIGNERS_SECRET") ?? "secret"))
    
    let homePath = app.directory.workingDirectory
    let certPath = homePath + "cert/cert.pem"
    let keyPath = homePath + "cert/key.pem"
    
    app.http.server.configuration.supportVersions = [.two]
    try app.http.server.configuration.tlsConfiguration = .forServer(
        certificateChain: [
            .certificate(.init(file: certPath,
                               format: .pem))
        ],
        privateKey: .file(keyPath)
    )

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)
    
    app.migrations.add(User.CreateMigration())
    app.migrations.add(UserToken.Migration())
    app.migrations.add(User.PrePopulateUser())

    // Run migration from within Xcode, because call to Bcrypt from command line fails on Swift < 5.3
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}
