//
//  File.swift
//
//
//  Created by Iván GalazJeria on 06-08-20.
//

import Fluent
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("login").grouped(User.authenticator())
        auth.post(use: login)
    }
    
    func login(req: Request) throws -> EventLoopFuture<UserToken> {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        return token.save(on: req.db).map { token }
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
