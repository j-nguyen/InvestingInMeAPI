
import Vapor
import HTTP
import JWT
import Foundation

/**
 AuthMiddleware to authenticate users to make sure it's set up
*/
final class AuthMiddleware: Middleware {
  
  private let config: Config
  
  init(_ config: Config) {
    self.config = config
  }
  
  func respond(to request: Request, chainingTo next: Responder) throws -> Response {
    // get our token string, if there isn't any then we know it doesn't exist
    guard let token = request.headers["Authorization"]?.string else {
      throw Abort(.forbidden, metadata: "No token found!")
    }
    
    // Attempt to load file
    guard let login = config["login", "key"]?.string else { throw Abort.serverError }
    
    // Attempt to verify token
    let jwt: JWT
    
    // attempt to verify the token here
    do {
      jwt = try JWT(token: token)
      try jwt.verifySignature(using: HS512(key: login.bytes))
    } catch {
      throw Abort(.unauthorized, metadata: "Token is either invalid, or something is wrong.")
    }
    
    // make sure the token isn't expired
    guard let exp = jwt.payload["exp"]?.int, TimeInterval(exp) > Date().timeIntervalSince1970 else {
      throw Abort(.unauthorized, metadata: "Expired Token, please re-login")
    }
    
    // attempt to get the payload
    let userId: Int = try jwt.payload.get("user_id")
    
    // attempt to find the user, and if it's not found, end it
    guard try User.find(userId) != nil else {
      throw Abort.notFound
    }
    
    // this is now our header where we can get our userId
    request.headers["user_id"] = String(userId)
    
    return try next.respond(to: request)
  }
}
