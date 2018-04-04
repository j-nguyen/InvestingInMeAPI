import Vapor

extension Droplet {
  func setupRoutes() throws {    
    // MARK: API Collection Routes
    try collection(V1Collection(cache))
    
    self.get("/") { req in
      return try self.view.make("index", ["project_count", try Project.count()])
    }
  }
}


