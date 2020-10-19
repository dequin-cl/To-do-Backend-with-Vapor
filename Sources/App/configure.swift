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
    let chainPath = homePath + "cert/chain.pem"
    let keyPath = homePath + "cert/key.pem"

    app.http.server.configuration.supportVersions = [.two]
    app.http.server.configuration.responseCompression = .enabled

    try app.http.server.configuration.tlsConfiguration = .forServer(
        certificateChain: [
            .certificate(.init(file: certPath,
                               format: .pem)),
            .certificate(.init(file: chainPath,
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
    
    app.migrations.add(User.CreateUser())
    app.migrations.add(User.CreateDefaultAdminUser())
    app.migrations.add(UserToken.CreateUserToken())

    // Run migration from within Xcode, because call to Bcrypt from command line fails on Swift < 5.3
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}
