@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    
    func testHelloWorld() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "hello") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        }
    }
    
    func testCreateTodo() throws {

        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        
        try app.test(.POST, "todos", beforeRequest: { req in
            try req.content.encode(
                Todo(title: "Test")
            )
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let todo = try res.content.decode(Todo.self)
            XCTAssertEqual(todo.title, "Test")
        })
    }
}
