import Vapor

extension Droplet {
  func setupRoutes() throws {    
    // MARK: API Collection Routes
    try collection(V1Collection.self)
  }
}
