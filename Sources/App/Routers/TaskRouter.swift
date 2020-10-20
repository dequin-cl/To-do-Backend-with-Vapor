//
//  File.swift
//  
//
//  Created by Iván on 19-10-20.
//

import Vapor

struct TaskRouter: RouteCollection {
    private let controller = TaskController()

    func boot(routes: RoutesBuilder) throws {
        let tasks = routes.grouped("tasks").grouped(UserToken.authenticator())
        
        tasks.post(use: controller.create)
    }
}
