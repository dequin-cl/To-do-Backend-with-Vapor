//
//  File.swift
//  
//
//  Created by Iván on 20-10-20.
//

import Fluent
import Vapor

func migrations(_ app: Application) throws {

    let migrations: [Migration] = [
        User.CreateUser(),
        User.CreateDefaultAdminUser(),
        UserToken.CreateUserToken(),
        Todo.CreateTodo(),
        Task.CreateTask()
    ]

    migrations.forEach{ app.migrations.add($0) }

    // Run migration from within Xcode, because call to Bcrypt from command line fails on Swift < 5.3
    try app.autoMigrate().wait()

}
