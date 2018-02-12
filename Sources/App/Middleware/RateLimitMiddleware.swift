//
//  RateLimitMiddleware.swift
//  App
//
//  Created by Johnny Nguyen on 2018-02-11.
//

import Foundation
import Vapor
import Cache
import HTTP

/**
 * Middleware used for rate-limiting on each specific account. This way we don't overload our servers with numerous amounts of requests.
 * This involves using redis for our scenario
*/
final class RateLimitMiddleware: Middleware {
  
  private let cache: CacheProtocol
  private let limit: Int
  private let refreshInterval: Double
  
  /// Iniitializing our rate limiting
  init(rate: Rate, cache: CacheProtocol = MemoryCache()) {
    self.cache = cache
    self.limit = rate.limit
    self.refreshInterval = rate.refreshInterval
  }
  
  func respond(to request: Request, chainingTo next: Responder) throws -> Response {
    
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
