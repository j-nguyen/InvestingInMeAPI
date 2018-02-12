//
//  RateLimitMiddleware.swift
//  App
//
//  Created by Johnny Nguyen on 2018-02-11.
//

import Foundation
import Vapor
import Cache
import RedisProvider
import HTTP

/**
 * Middleware used for rate-limiting on each specific account. This way we don't overload our servers with numerous amounts of requests.
 * This involves using redis for our scenario
*/
final class RateLimitMiddleware: Middleware {
  
  private let cache: CacheProtocol
  private let limit: Int
  private let refreshInterval: Double
  
  /// Initializing our rate limiting
  init(rate: Rate, cache: CacheProtocol) {
    self.cache = cache
    self.limit = rate.limit
    self.refreshInterval = rate.refreshInterval
  }
  
  func respond(to request: Request, chainingTo next: Responder) throws -> Response {
    // First, we want to check for the header's userId
    guard let userId = request.headers["user_id"]?.string else {
      throw Abort(.forbidden, reason: "Unable to verify user")
    }
    
    // next thing is to attempt to cache the userId
    var userCache = try cache.get(userId)
    
    // and then set the values right after. We need one for the request limit, and then the date of which it was called
    var createdAt = userCache?["createdAt"]?.double ?? Date().timeIntervalSince1970
    var requestsLeft = userCache?["requestsLeft"]?.int ?? limit
    
    // get the date for now and check if the current now is greater and if it is then we have to adjust
    let now = Date().timeIntervalSince1970
    
    if now - createdAt >= refreshInterval {
      createdAt = now
      requestsLeft = limit
    }
    
    // next is make sure we set our cache
    // defer will print at thend of the function so we won't have to worry until later
    defer {
      do {
        try cache.set(userId, Node(node: [
          "createdAt": createdAt,
          "requestsLeft": requestsLeft
        ]))
      } catch let e {
        print ("Error: \(e)")
      }
    }
    
    print (requestsLeft)
    // subtract the requests after, since a request has been made
    requestsLeft -= 1
    
    // check to make sure the requests haven't gone up like crazy
    guard requestsLeft >= 0 else {
      throw Abort(.tooManyRequests, reason: "Slow down! Please try again later")
    }
    
    return try next.respond(to: request)
  }
}


/// Rate class to declare our rate limiting service
public struct Rate {
  public enum Interval {
    case second
    case minute
    case hour
    case day
  }

  // MARK: Properties
  
  // the limit is the amount of times before it hits this
  public let limit: Int
  public let interval: Interval
  
  public init(_ limit: Int, interval: Interval) {
    self.limit = limit
    self.interval = interval
  }
  
  public var refreshInterval: Double {
    switch interval {
    case .second:
      return 1
    case .minute:
      return 60
    case .hour:
      return 3600
    case .day:
      return 86400
    }
  }
}
