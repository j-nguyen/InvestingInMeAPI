//
//  RateLimitMiddleware.swift
//  App
//
//  Created by Johnny Nguyen on 2018-02-11.
//

import Foundation
import Vapor
import HTTP

/**
 * Middleware used for rate-limiting on each specific account. This way we don't overload our servers with numerous amounts of requests.
 * This involves using redis for our scenario
*/
final class RateLimitMiddleware: Middleware {
  func respond(to request: Request, chainingTo next: Responder) throws -> Response {
    
    return try next.respond(to: request)
  }
}
