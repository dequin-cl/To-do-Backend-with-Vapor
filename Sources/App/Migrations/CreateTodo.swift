import Fluent

extension Todo {
    struct CreateTodo: Migration {
        var name: String { "Create Todo" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            return database.schema("todos")
                .id()
                .field("title", .string, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            return database.schema("todos").delete()
        }
    }
}
