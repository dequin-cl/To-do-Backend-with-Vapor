import Fluent

struct CreateTask: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("tasks")
            .id()
            .field("name", .string)
            .field("todo_id", .uuid, .references("todos", "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("tasks").delete()
    }
}
