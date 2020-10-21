//
//  File.swift
//  
//
//  Created by Iván on 21-10-20.
//

import Vapor

struct DocsRouter: RouteCollection {
    private var controller:APIDocsController!
    
    init(_ app: Application) {
        controller = APIDocsController(app: app)
    }

    func boot(routes: RoutesBuilder) throws {
        let docs = routes.grouped("docs")
        
        docs.get(use: controller.view)
            .summary("View API Documentation")
            .description("API Documentation is served using the Redoc web app.")
            .tags("Documentation")
        
        docs.get("openapi.yml", use: controller.show)
            .summary("Download API Documentation")
            .description("Retrieve the OpenAPI documentation as a YAML file.")
            .tags("Documentation")
    }
}

