import Vapor

extension Droplet {
  func setupRoutes() throws {    
    // MARK: API Collection Routes
    try collection(V1Collection(cache: cache, config: config))
    
    get("/") { [weak self] req in
      guard let this = self else { throw Abort.notFound }
      return try this.view.make("index", ["project_count": Project.count()])
    }
  }
}


