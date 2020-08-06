import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let homePath = app.directory.workingDirectory
    let certPath = homePath + "cert/cert.pem"
    let keyPath = homePath + "cert/key.pem"
    
    let certs = try! NIOSSLCertificate.fromPEMFile(certPath)
        .map { NIOSSLCertificateSource.certificate($0) }
    let tls = TLSConfiguration.forServer(certificateChain: certs, privateKey: .file(keyPath))

    app.http.server.configuration = .init(hostname: "127.0.0.1",
                                          port: 8080,
                                          backlog: 256,
                                          reuseAddress: true,
                                          tcpNoDelay: true,
                                          responseCompression: .disabled,
                                          requestDecompression: .disabled,
                                          supportPipelining: false,
                                          supportVersions: Set<HTTPVersionMajor>([.two]),
                                          tlsConfiguration: tls,
                                          serverName: nil,
                                          logger: nil)

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    app.migrations.add(CreateTodo())
    app.migrations.add(AddAddressTodo())
    app.migrations.add(CreateTask())

    // register routes
    try routes(app)
}
