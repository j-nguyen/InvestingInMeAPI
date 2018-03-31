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
  func index(_ req: Request) throws -> ResponseRepresentable {
    guard let userId = req.headers["user_id"]?.int else {
      throw Abort.badRequest
    }
    
    let notifications = try Notification.makeQuery().filter("user_id", userId).all()
    
    return try notifications.makeJSON()
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
      .and({ try $0.filter("user_id", userId) })
      .first() else {
        throw Abort.notFound
    }
    
    try notification.delete()
    
    return Response(status: .ok)
  }
}
