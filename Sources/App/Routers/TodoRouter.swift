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
        let todos = routes.grouped("todos")
        todos.get(use: controller.index)
        todos.post(use: controller.create)
        todos.group(":todoID") { todo in
            todo.delete(use: controller.delete)
        }
    }
}
