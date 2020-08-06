//
//  File.swift
//  
//
//  Created by Iván GalazJeria on 06-08-20.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)
        
        let token = routes.grouped("me").grouped(UserToken.authenticator())
        token.get(use: getMe)
        
        let jwt = routes.grouped("mee")
        jwt.get(use: mee)
        
    }
    
    func create(req: Request) throws -> EventLoopFuture<User> {
        try User.Create.validate(content: req)
        
        let create = try req.content.decode(User.Create.self)
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
    
    func getMe(req: Request) throws -> User {
        try req.auth.require(User.self)
    }
    
    func mee(req: Request) throws -> HTTPStatus {
        let payload = try req.jwt.verify(as: TestPayload.self)
        print(payload)
        return .ok
    }
}

/*
 // POST
 {
     "name": "Vapor",
     "email": "test@vapor.codes",
     "password": "secret42",
     "confirmPassword": "secret42"
 }
 
 // RESPONSE
 {
     "email": "test@vapor.codes",
     "id": "BD180E6D-2450-4FDA-941D-E4C25330F1BA",
     "name": "Vapor",
     "passwordHash": "$2b$12$HWdXE2UUXFTeGAN4A76rY.u9NjT2S5momWfpCr0VDo8olxcaDV1b6"
 }
 
 */
