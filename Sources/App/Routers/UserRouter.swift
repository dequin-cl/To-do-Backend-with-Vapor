//
//  File.swift
//  
//
//  Created by Iván on 19-10-20.
//

import Vapor

struct UserRouter: RouteCollection {
    private let controller = UserController()

    func boot(routes: RoutesBuilder) throws {

        let users = routes.grouped("users")
        users.grouped(User.authenticator()).grouped("login").post(use: controller.loginUser)

        let tokenProtected = users.grouped(UserToken.authenticator())

        tokenProtected.get(use: controller.profile)
        tokenProtected.grouped("logout").get(use: controller.logout)

    }
}
