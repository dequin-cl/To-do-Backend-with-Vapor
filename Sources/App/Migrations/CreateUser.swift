//
//  File.swift
//  
//
//  Created by Iván GalazJeria on 06-08-20.
//

import Fluent
import Vapor

extension User {
    struct CreateMigration: Fluent.Migration {
        var name: String { "CreateUser" }
        
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

    struct PrePopulateUser: Migration {

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            let password = try? Bcrypt.hash(Environment.get("FIRST_USER_PASSWORD") ?? "secret")
            guard let hashedPassword = password else {
                fatalError("Failed to create admin user")
            }
            let admin = User(
                name: Environment.get("FIRST_USER_NAME") ?? "dummy",
                email: Environment.get("FIRST_USER_EMAIL") ?? "dummy@ecorp.org.lab",
                passwordHash: hashedPassword,
                isAdmin: true)

            return admin.save(on: database)
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            return User
                .query(on: database)
                .filter(\User.$name, .equal, Environment.get("FIRST_USER_NAME") ?? "dummy")
                .delete()
        }
    }
}
