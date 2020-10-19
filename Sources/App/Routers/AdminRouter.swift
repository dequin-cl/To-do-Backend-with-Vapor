//
//  File.swift
//
//
//  Created by Iván on 19-10-20.
//

import Vapor

struct AdminRouter: RouteCollection {
    private let controller = AdminController()

    func boot(routes: RoutesBuilder) throws {
        
        let admins = routes.grouped("admins")
        admins.grouped("createUser").post(use: controller.create)
        admins.grouped("login").post(use: controller.login)

        admins.get(use: controller.me)
    }
}
