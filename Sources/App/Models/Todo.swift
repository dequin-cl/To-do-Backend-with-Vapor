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

    @Group(key: "address")
    var address: Address

    init() { }

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }

    init(id: UUID? = nil, title: String, address: Address) {
        self.id = id
        self.title = title
        self.address = address
    }
}

final class Address: Fields {
    
    @OptionalField(key: "street")
    var street: String?
    
    @Field(key: "number")
    var number: Int
    
    @OptionalField(key: "other_information")
    var otherInformation: String?
}
