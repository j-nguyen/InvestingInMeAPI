import Vapor
import Cache
import HTTP

/**
 This V1Collection class is to help us organize our routes correctly.
 this route will be specified as `/api/v1/`, as a way to simplify and make our routing
 much easier.
 We conform to RouteCollection so that we can start grouping.
*/
final class V1Collection: RouteCollection {
  
  private let cache: CacheProtocol
  
  public init(_ cache: CacheProtocol) {
    self.cache = cache
  }
  
  /**
    Builds and organizes the route for us
  */
  func build(_ builder: RouteBuilder) throws {
    
    //Declare the group route for the api
    let api = builder.grouped("api", "v1")
    
    //Declare the Controllers
    let userController = UserController()
    let projectController = ProjectController()
    let connectionController = ConnectionController()
    let featuredProjectController = FeaturedProjectController()
    let assetController = AssetController()
    
    // Declare the middlewares
    let authMiddleware = AuthMiddleware()
    let rateMiddleware = RateLimitMiddleware(rate: Rate(15, interval: .second), cache: cache)
    
    //MARK: User Routes
    api.group("users") { user in
      user.grouped(authMiddleware, rateMiddleware).get(":id", handler: userController.show)
      user.grouped(authMiddleware, rateMiddleware).patch(":id", handler: userController.update)
      user.grouped(authMiddleware, rateMiddleware).get(":id","projects", handler: userController.userProjects)
      user.grouped(authMiddleware, rateMiddleware).post(":id", "projects", handler: userController.createProject)
      user.grouped(authMiddleware, rateMiddleware).get(":id", "connections", handler: userController.connection)
      user.get("roles", handler: userController.roles)
      user.post("login", handler: userController.login)
    }
    
    // MARK: Asset Routes
    api.grouped(authMiddleware, rateMiddleware).group("assets") { asset in
      asset.post("/", handler: assetController.create)
      asset.delete(":id", handler: assetController.delete)
    }
    
    //MARK: Project Routes
    api.grouped(authMiddleware, rateMiddleware).group("projects") { project in
      project.get("/", handler: projectController.index)
      project.get(":id", handler: projectController.show)
      project.patch(":id", handler: projectController.update)
      project.delete(":id", handler: projectController.delete)
      project.get("categories", handler: projectController.categories)
    }
    
    //MARK: Connection Routes
    api.grouped(authMiddleware, rateMiddleware).group("connections") { connection in
      connection.get(":id", handler: connectionController.show)
      connection.patch(":id", handler: connectionController.update)
      connection.post("/", handler: connectionController.create)
      connection.delete(":id", handler: connectionController.delete)
      connection.get("doesExist", handler: connectionController.doesExist)
    }
    
    //MARK: Featured Project Routes
    api.grouped(authMiddleware, rateMiddleware).group("featured") { featured_project in
      featured_project.get("/", handler: featuredProjectController.index)
      featured_project.post("/", handler: featuredProjectController.create)
      featured_project.delete(":id", handler: featuredProjectController.delete)
    }
  }
}
