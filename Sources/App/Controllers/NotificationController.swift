//
//  NotificationController.swift
//  App
//
//  Created by Johnny Nguyen on 2018-03-30.
//

import Foundation
import Vapor
import HTTP
import FluentProvider

final class NotificationController {
  
  private let config: Config
  
  init(_ config: Config) {
    self.config = config
  }
  
  func index(_ req: Request) throws -> ResponseRepresentable {
    guard let userId = req.headers["user_id"]?.int else {
      throw Abort.badRequest
    }
    
    let notifications = try Notification.makeQuery().filter("owner_id", userId)
    
    // We'll set up search queries to make sure that it sorts, or it only gets read ones
    if let sort = req.query?["search"]?.string {
      if sort == "desc" {
        try notifications.sort("created_at", .descending)
      } else if sort == "asc" {
        try notifications.sort("created_at", .ascending)
      }
    }
    
    // Check now to only show read ones
    if let read = req.query?["read"]?.bool {
      try notifications.filter("has_read", read)
    }
    
    return try notifications.all().makeJSON()
  }
  
  func delete(_ req: Request) throws -> ResponseRepresentable {
    guard let userId = req.headers["user_id"]?.int else {
      throw Abort.badRequest
    }
    
    guard let notificationId = req.parameters["id"]?.int else {
      throw Abort.badRequest
    }
    
    guard let notification = try Notification.makeQuery()
      .filter("id", notificationId)
      .and({ try $0.filter("owner_id", userId) })
      .first() else {
        throw Abort.notFound
    }
    
    try notification.delete()
    
    return Response(status: .ok)
  }
}
