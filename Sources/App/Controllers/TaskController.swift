import Fluent
import Vapor

struct TaskController {
    
    func create(req: Request) throws -> EventLoopFuture<Task> {
        let task = try req.content.decode(Task.self)
        return task.save(on: req.db).map{ task }
    }
}
