import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    try app.register(collection: TodoController())
    try app.register(collection: TaskController())
    try app.register(collection: UserController())
    try app.register(collection: AuthController())
    
//    let passwordProtected = app.grouped(User.authenticator())
//    passwordProtected.post("login") { req -> User in
//        
//        try req.auth.require(User.self)
//    }
}
