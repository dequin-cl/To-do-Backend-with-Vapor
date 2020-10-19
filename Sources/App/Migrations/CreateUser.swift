//
//  File.swift
//  
//
//  Created by Iván GalazJeria on 06-08-20.
//

import Fluent
import Vapor

extension User {
    struct CreateUser: Fluent.Migration {
        var name: String { "Create User" }
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users")
                .id()
                .field("name", .string, .required)
                .field("email", .string, .required)
                .field("password_hash", .string, .required)
                .field("is_admin", .bool, .required, .custom("DEFAULT FALSE"))
                .unique(on: "email")
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users").delete()
        }
    }

    struct CreateDefaultAdminUser: Migration {
        var name: String { "Create Admin" }
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {

            let password = try? Bcrypt.hash(Utils.getFromEnvironment("FIRST_USER_PASSWORD", default: "secret"))
            guard let hashedPassword = password else {
                fatalError("Failed to create admin user")
            }
            let admin = User(
                name: Utils.getFromEnvironment("FIRST_USER_NAME", default: "dummy"),
                email: Utils.getFromEnvironment("FIRST_USER_EMAIL", default: "dummy@ecorp.org.lab"),
                passwordHash: hashedPassword,
                isAdmin: true)

            return admin.save(on: database)
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            return User
                .query(on: database)
                .filter(\User.$name, .equal, Utils.getFromEnvironment("FIRST_USER_NAME", default: "dummy"))
                .delete()
        }
    }
}
