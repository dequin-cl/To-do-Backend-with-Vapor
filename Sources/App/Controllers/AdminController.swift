//
//  File.swift
//  
//
//  Created by Iván on 19-10-20.
//

import Vapor

struct AdminController {
    // MARK:- Administrators
    func create(req: Request) throws -> EventLoopFuture<User> {
        let payload = try req.jwt.verify(as: AdminJWTPayload.self)

        return User
            .find(UUID(uuidString: payload.subject.value), on: req.db)
            .flatMapThrowing{ protoAdmin -> User in

                guard let protoAdmin = protoAdmin, protoAdmin.isAdmin else {
                    throw Abort(.unauthorized)
                }

                try UserDTO.Create.validate(content: req)

                let create = try req.content.decode(UserDTO.Create.self)
                guard create.password == create.confirmPassword else {
                    throw Abort(.badRequest, reason: "Passwords did not match")
                }

                return try User(
                    name: create.name,
                    email: create.email,
                    passwordHash: Bcrypt.hash(create.password)
                )
            }
            .flatMap { user -> EventLoopFuture<User> in
                return user.save(on: req.db)
                    .map {user}
            }
    }

    func me(req: Request) throws -> EventLoopFuture<AdminDTO> {
        let payload = try req.jwt.verify(as: AdminJWTPayload.self)

        return User
            .find(UUID(uuidString: payload.subject.value), on: req.db)
            .unwrap(or: Abort(.notFound))
            .map { (user) -> AdminDTO in
                AdminDTO(from: user)
            }
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
                let payload = AdminJWTPayload(
                    subject: .init(value: try user.requireID().uuidString),
                    expiration: .init(value: .distantFuture),
                    isAdmin: true
                )

                return try NewSession(token: req.jwt.sign(payload), user: UserDTO(from: user))
            }
    }
}
