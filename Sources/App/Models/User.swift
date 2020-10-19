//
//  File.swift
//  
//
//  Created by Iván GalazJeria on 06-08-20.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String

    @Field(key: "is_admin")
    var isAdmin: Bool
    
    init() {    }
    
    init(id: UUID? = nil, name: String, email: String, passwordHash: String, isAdmin: Bool = false) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.isAdmin = isAdmin
    }
}

// MARK:- Authentication Validate Password
extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

// MARK:- Token Authentication
extension User {
    func generateToken() throws -> UserToken {
        try .init(
            value: UUID().uuidString,
            userID: self.requireID()
        )
    }
}
