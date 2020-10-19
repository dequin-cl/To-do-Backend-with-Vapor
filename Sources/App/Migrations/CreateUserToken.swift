//
//  File.swift
//  
//
//  Created by Iván GalazJeria on 06-08-20.
//

import Fluent

extension UserToken {
    struct CreateUserToken: Fluent.Migration {
        var name: String { "Create User Token" }
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("user_tokens")
                .id()
                .field("value", .string, .required)
                .field("user_id", .uuid, .required, .references("users", "id"))
                .unique(on: "value")
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("user_tokens").delete()
        }
    }
}
