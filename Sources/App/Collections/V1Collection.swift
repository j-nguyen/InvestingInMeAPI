import Vapor
import HTTP

/**
 This V1Collection class is to help us organize our routes correctly.
 this route will be specified as `/api/v1/`, as a way to simplify and make our routing
 much easier.
 We conform to RouteCollection so that we can start grouping. EmptyInitializable just means that we can
 add our class without needed to initialize the class
*/
final class V1Collection: RouteCollection, EmptyInitializable {
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
    
    //MARK: User Routes
    api.group("users") { user in
      user.get(":id", handler: userController.show)
      user.patch(":id", handler: userController.update)
      user.get(":id","projects", handler: userController.userProjects)
    }
    
    // MARK: Asset Routes
    api.group("assets") { asset in
      asset.post("/", handler: assetController.create)
      asset.delete(":id", handler: assetController.delete)
    }
    
    //MARK: Project Routes
    api.group("projects") { project in
      project.get("/", handler: projectController.index)
      project.get(":id", handler: projectController.show)
      project.post("/", handler: projectController.create)
      project.patch(":id", handler: projectController.update)
      project.delete(":id", handler: projectController.delete)
    }
    
    //MARK: Connection Routes
    api.group("connections") { connection in
      connection.get(":id", handler: connectionController.show)
      connection.patch(":id", handler: connectionController.update)
      connection.post("/", handler: connectionController.create)
      connection.delete(":id", handler: connectionController.delete)
    }
    
    //MARK: Featured Project Routes
    api.group("featured") { featured_project in
      featured_project.get("/", handler: featuredProjectController.index)
      featured_project.post("/", handler: featuredProjectController.create)
      featured_project.delete(":id", handler: featuredProjectController.delete)
    }
  }
}
