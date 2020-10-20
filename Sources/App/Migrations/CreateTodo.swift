import Fluent

extension Todo {
    struct CreateTodo: Migration {
        var name: String { "Create Todo" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            return database.schema("todos")
                .id()
                .field("user_id", .uuid, .references("users", "id"))
                .field("title", .string, .required)
                .field("created_at", .datetime)
                .field("updated_at", .datetime)
                .field("deleted_at", .datetime)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            return database.schema("todos").delete()
        }
    }
}
