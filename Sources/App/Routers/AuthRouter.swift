//
//  File.swift
//  
//
//  Created by Iván on 19-10-20.
//

import Vapor

struct AuthRouter: RouteCollection {
    private let controller = AuthController()

    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("login").grouped(User.authenticator())
        auth.post(use: controller.login)
    }
}
