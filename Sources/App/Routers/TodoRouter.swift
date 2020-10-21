//
//  File.swift
//  
//
//  Created by Iván on 19-10-20.
//

import Vapor

struct TodoRouter: RouteCollection {
    private let controller = TodoController()

    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos").grouped(UserToken.authenticator())

        todos.get(use: controller.index)
        todos.post(use: controller.create)
        
        todos.group(":id") { todo in
            todo.delete(use: controller.delete)
            todo.get(use: controller.info)
                .summary("View ToDo's information")
                .description("Shows complete information for a given ToDo identifier.")
                .tags("Todo User")

        }
    }
}
