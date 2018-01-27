
import Vapor
import HTTP
import JWT

final class AuthMiddleware: Middleware {
  func respond(to request: Request, chainingTo next: Responder) throws -> Response {
    
    guard let token = request.headers["Authorization"]?.string else {
      throw Abort(.notFound, reason: "Authorization header not found or invalid.")
    }
    
    let jwt = try JWT(token: token)
    
    guard let keys = try GoogleService.getJWTKeys(token: jwt)
      else {
        throw Abort.serverError
    }
    
   guard let _ = try? jwt.verifySignature(using: RS256(rsaKey: RSAKey(n: keys.n, e: keys.e)))
    else {
      throw Abort.serverError
    }
    
    
    
    return try next.respond(to: request)
  }
  
  
}
