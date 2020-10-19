//
//  File.swift
//  
//
//  Created by Iván on 10-08-20.
//

import Vapor

// Login

struct UserDTO: Content {
    let fullName: String
    let email: String
    let isAdmin: Bool

    init(fullName: String, email: String, isAdmin: Bool) {
        self.fullName = fullName
        self.email = email
        self.isAdmin = isAdmin
    }

    init(from user: User) {
        self.init(fullName: user.name, email: user.email, isAdmin: user.isAdmin)
    }
}

extension UserDTO {
    struct Create: Content {
        var name: String
        var email: String
        var password: String
        var confirmPassword: String
    }

    struct LoginForm: Content {
        let user: Login
    }

    struct Login: Content {
        let email: String
        let password: String
    }
}

// MARK:- Validation for Creation
extension UserDTO.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension UserDTO.Login: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: !.empty)
    }
}
