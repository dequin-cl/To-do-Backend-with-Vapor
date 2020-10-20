//
//  File.swift
//  
//
//  Created by Iván on 20-10-20.
//

import Vapor

struct TodoDTO: Content {
    let id: String?
    let updatedAt: Date?
    let title: String
    let tasks: [TaskDTO]?

    init(_ todo: Todo) {
        self.id = todo.id?.uuidString
        self.title = todo.title
        self.updatedAt = todo.updatedAt

        if !todo.tasks.isEmpty {
            var tasks: [TaskDTO] = []
            todo.tasks.forEach {
                tasks.append(TaskDTO(task: $0))
            }
            self.tasks = tasks
        } else {
            self.tasks = nil
        }
    }
}

struct CreateTodoDTO: Content {
    let id: String?
    let title: String

    init(_ todo: Todo) {
        self.id = todo.id?.uuidString
        self.title = todo.title
    }
}
