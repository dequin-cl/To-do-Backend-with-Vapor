import Fluent

struct CreateTodo: Migration {
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

struct AddAddressTodo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos")
            .field("address_street", .string)
            .field("address_number", .int)
            .field("address_other_information", .string)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos").delete()
    }
}
