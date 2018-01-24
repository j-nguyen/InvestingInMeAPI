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
    
  }
}
