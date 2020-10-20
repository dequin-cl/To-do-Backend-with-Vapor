import Fluent
import Vapor

final class Todo: Model, Content {
    static let schema = "todos"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Children(for: \.$todo)
    var tasks: [Task]

    @Parent(key: "user_id")
    var user: User

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(id: UUID? = nil, title: String, owner: User.IDValue) {
        self.id = id
        self.title = title
        self.$user.id = owner
    }

    convenience init(user: User, todoDTO: TodoDTO) {
        self.init(id: nil,
                  title: todoDTO.title,
                  owner: user.id!)
    }
}
