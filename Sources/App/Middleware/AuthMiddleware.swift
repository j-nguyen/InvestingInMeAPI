
import Vapor
import HTTP

final class AuthMiddleware: Middleware {
  func respond(to request: Request, chainingTo next: Responder) throws -> Response {
    return try next.respond(to: request)
  }
  
  
}
