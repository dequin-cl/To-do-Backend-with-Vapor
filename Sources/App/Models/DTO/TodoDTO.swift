//
//  File.swift
//  
//
//  Created by Iván on 20-10-20.
//

import Vapor

import Sampleable
import OpenAPIKit
import OpenAPIReflection


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
    
    init(_ title: String) {
        self.id = nil
        self.updatedAt = nil
        self.title = title
        self.tasks = nil
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


extension TodoDTO: ResponseEncodable {
    func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        return request.eventLoop
            .makeSucceededFuture(())
            .flatMapThrowing {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy =  .iso8601
                
                return try Response(body: .init(data: encoder.encode(self)))
            }
    }
}

extension TodoDTO: Sampleable {
    static var sample: TodoDTO {
        .init("Sample")
    }
}

extension TodoDTO: OpenAPIEncodedSchemaType {
    static func openAPISchema(using encoder: JSONEncoder) throws -> JSONSchema {
        return try genericOpenAPISchemaGuess(using: encoder)
    }
}
