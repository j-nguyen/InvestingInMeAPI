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
    
    //MARK: User Routes
    //Declare the group for the users
    api.group("users") { user in
      user.get(":id", handler: userController.show)
      user.patch(":id", handler: userController.update)
    }
    
    api.group("projects") { project in
      project.get("/", handler: projectController.index)
      project.get(":id", handler: projectController.show)
      project.patch(":id", handler: projectController.update)
    }
  }
}
