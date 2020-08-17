//
//  File.swift
//  
//
//  Created by Iván GalazJeria on 06-08-20.
//

import Fluent
import Vapor

struct NewSession: Content {
    let token: String
    let user: UserDTO
}

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let admins = routes.grouped("admins")
        admins.grouped("createUser").post(use: create)
        admins.grouped("login").post(use: login)

        admins.get(use: me)

        let users = routes.grouped("users")
        users.grouped("login").post(use: loginUser)

        let tokenProtected = users.grouped(UserToken.authenticator())

        tokenProtected.get(use: profile)
        tokenProtected.grouped("logout").get(use: logout)

    }

    // MARK:- Administrators
    func create(req: Request) throws -> EventLoopFuture<User> {
        _ = try req.jwt.verify(as: TestPayload.self)

        let protoAdmin: User = try req.auth.require(User.self)

        if !protoAdmin.isAdmin {
                throw Abort(.unauthorized)
        }
        
        try UserDTO.Create.validate(content: req)
        
        let create = try req.content.decode(UserDTO.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        
        let user = try User(
            name: create.name,
            email: create.email,
            passwordHash: Bcrypt.hash(create.password)
        )
        
        return user.save(on: req.db)
            .map {user}
    }

    func me(req: Request) throws -> HTTPStatus {
        _ = try req.jwt.verify(as: TestPayload.self)
        
        return .ok
    }
    
    func login(req: Request) throws -> EventLoopFuture<NewSession> {

        let userForm = try req.content.decode(UserDTO.LoginForm.self)

        return User
            .query(on: req.db)
            .filter(\User.$email, .equal, userForm.user.email)
            .first()
            .flatMapThrowing { user -> User in
                guard let user = user,
                    try Bcrypt.verify(userForm.user.password, created: user.passwordHash) else {
                        throw Abort(.unauthorized)
                }
                return user
        }
        .flatMapThrowing { user -> NewSession in
            let payload = TestPayload(
                subject: .init(value: "vapor\(user.name)"),
                expiration: .init(value: .distantFuture)
            )

            return try NewSession(token: req.jwt.sign(payload), user: UserDTO(from: user))
        }
    }

    // MARK:- Users
    func loginUser(req: Request) throws -> EventLoopFuture<NewSession> {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()

        return token.save(on: req.db).flatMapThrowing {
            NewSession(token: token.value, user: UserDTO(from: user))
        }
    }

    func profile(req: Request) throws -> UserDTO {
        let user: User = try req.auth.require(User.self)

        return UserDTO(from: user)
    }

    func logout(req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        let user: User = try req.auth.require(User.self)

        return try UserToken
            .query(on: req.db)
            .filter(\UserToken.$user.$id, .equal, user.requireID())
            .delete()
            .transform(to: HTTPResponseStatus.ok)
        
    }
}
