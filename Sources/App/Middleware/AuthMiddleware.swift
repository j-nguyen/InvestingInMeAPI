
import Vapor
import HTTP
import JWT
import Foundation

/**
 AuthMiddleware to authenticate users to make sure it's set up
*/
final class AuthMiddleware: Middleware {
  func respond(to request: Request, chainingTo next: Responder) throws -> Response {
    

    
    return try next.respond(to: request)
  }
  
  
}
g
