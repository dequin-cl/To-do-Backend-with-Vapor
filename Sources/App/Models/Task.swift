import Fluent
import Vapor

final class Task: Model, Content {
    // Name of the table or collection.
    static let schema = "tasks"

    // Unique identifier for this Star.
    @ID(key: .id)
    var id: UUID?

    // The Star's name.
    @Field(key: "name")
    var name: String

    // Reference to the Todo this Task is in.
    @Parent(key: "todo_id")
    var todo: Todo

    // Creates a new, empty Star.
    init() { }

    // Creates a new Star with all properties set.
    init(id: UUID? = nil, name: String, todoID: UUID) {
        self.id = id
        self.name = name
        self.$todo.id = todoID
    }
}
