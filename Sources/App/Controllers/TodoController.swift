import Fluent
import Vapor

struct TodoController {

    func index(req: Request) throws -> EventLoopFuture<[TodoDTO]> {
        return Todo
            .query(on: req.db)
            .with(\.$tasks)
            .all()
            .map { todos -> [TodoDTO] in
                todos.map{TodoDTO($0)}
            }
    }

    func create(req: Request) throws -> EventLoopFuture<CreateTodoDTO> {
        let user: User = try req.auth.require(User.self)
        let todoDTO = try req.content.decode(TodoDTO.self)

        let todo = Todo(user: user, todoDTO: todoDTO)

        return todo
            .save(on: req.db)
            .map { CreateTodoDTO(todo) }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Todo
            .find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }

    func info(req: Request) throws -> EventLoopFuture<TodoDTO> {
        guard let todoUUID = req.parameters.get("id", as: UUID.self) else { throw Abort(.notFound) }

        return Todo
            .query(on: req.db)
            .filter(\.$id == todoUUID)
            .with(\.$tasks)
            .first()
            .map { todo -> TodoDTO in
                TodoDTO(todo!)
            }
    }
}
