//
//  File.swift
//  
//
//  Created by Iván on 20-10-20.
//

import Vapor

struct TaskDTO: Codable {
    let id: String
    let name: String

    init(task: Task) {
        self.id = task.id!.uuidString
        self.name = task.name
    }
}
