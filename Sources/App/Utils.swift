//
//  File.swift
//  
//
//  Created by Iván on 19-10-20.
//

import Vapor

struct Utils {
    static func getFromEnvironment(_ key: String, `default`: String) -> String {
        let candidate = Environment.get(key)

        if let result = candidate, !result.isEmpty {
            return result
        }

        return `default`
    }
}
