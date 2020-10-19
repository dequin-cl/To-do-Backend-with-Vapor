//
//  File.swift
//  
//
//  Created by Iván on 19-10-20.
//

import Vapor

struct AdminDTO: Content {
    let name: String
    let email: String

    init(name: String, email: String) {
        self.name = name
        self.email = email
    }

    init(from user: User) {
        self.init(name: user.name, email: user.email)
    }
}
