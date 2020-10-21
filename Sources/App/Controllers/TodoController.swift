import Fluent
import Vapor
import VaporOpenAPI

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

    func info(req: TypedRequest<InfoContext>) throws -> EventLoopFuture<Response> {
        guard let todoUUID = req.parameters.get("id", as: UUID.self) else { throw Abort(.notFound) }

        return Todo
            .query(on: req.db)
            .filter(\.$id == todoUUID)
            .with(\.$tasks)
            .first()
            .flatMap { todo -> EventLoopFuture<Response> in
                guard let todo = todo else {
                    return req.response.notFound
                }
                return req.response.success.encode(TodoDTO(todo))
            }
    }
}

extension TodoController {
    struct InfoContext: RouteContext {
        typealias RequestBodyType = EmptyRequestBody
        
        static var defaultContentType: HTTPMediaType? = nil
        static var shared = Self()
        
        let success: ResponseContext<TodoDTO> = .init { response in
            response.headers.contentType = .json
            response.status = .ok
        }
        
        let notFound: CannedResponse<String> = .init(
            response: Response(
                status: .notFound,
                headers: ["Content-Type": "text/plain"],
                body: .init(string: "There's no ToDo with suplied identifier")))
    }
}
