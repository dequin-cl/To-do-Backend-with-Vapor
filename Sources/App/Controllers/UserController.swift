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

struct UserController {

    // MARK:- Users
    func signIn(req: Request) throws -> EventLoopFuture<NewSession> {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()

        return token
            .save(on: req.db)
            .flatMapThrowing {
                NewSession(token: token.value, user: UserDTO(from: user))
            }
    }

    func profile(req: Request) throws -> UserDTO {
        let user: User = try req.auth.require(User.self)

        return UserDTO(from: user)
    }

    func signOut(req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        let user: User = try req.auth.require(User.self)

        return try UserToken
            .query(on: req.db)
            .filter(\UserToken.$user.$id, .equal, user.requireID())
            .delete()
            .transform(to: HTTPResponseStatus.ok)
        
    }
}
