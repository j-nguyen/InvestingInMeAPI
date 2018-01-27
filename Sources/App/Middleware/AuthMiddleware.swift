
import Vapor
import HTTP
import JWT
import Foundation

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
    
    guard let aud = jwt.payload["aud"]?.string, let client_id = drop?.config["google", "client_id"]?.string, aud == client_id else
    {
      throw Abort(.unauthorized, reason: "Invalid login credentials.")
    }
    
    guard let iss = jwt.payload["iss"]?.string, iss == "https://accounts.google.com" else {
      throw Abort(.unauthorized, reason: "Invalid login credentials.")
    }
    
    guard let exp = jwt.payload["exp"]?.int, TimeInterval(exp) > Date().timeIntervalSince1970 else {
      throw Abort(.unauthorized, reason: "Expired Token, please re-login")
    }
    
    return try next.respond(to: request)
  }
  
  
}
