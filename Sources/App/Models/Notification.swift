//
//  Notification.swift
//  App
//
//  Created by Johnny Nguyen on 2018-03-30.
//

import Foundation
import Vapor
import FluentProvider

final class Notification: Model, Timestampable {
  let storage: Storage = Storage()
  
  // MARK: Properties
  var user_id: Identifier
  var owner_id: Identifier
  var message: String
  var type: String
  var type_id: Int
  var have_read: Bool = false
  
  init(owner_id: Identifier, user_id: Identifier, message: String, type: String, type_id: Int, have_read: Bool = false) {
    self.owner_id = owner_id
    self.user_id = user_id
    self.message = message
    self.type = type
    self.type_id = type_id
    self.have_read = have_read
  }
  
  init(row: Row) throws {
    owner_id = try row.get("owner_id")
    user_id = try row.get("user_id")
    message = try row.get("message")
    type = try row.get("type")
    type_id = try row.get("type_id")
    have_read = try row.get("have_read")
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("owner_id", owner_id)
    try row.set("user_id", user_id)
    try row.set("message", message)
    try row.set("type", type)
    try row.set("type_id", type_id)
    try row.set("have_read", have_read)
    return row
  }
}

extension Notification {
  var user: Parent<Notification, User> {
    return parent(id: user_id)
  }
  
  var owner: Parent<Notification, User> {
    return parent(id: owner_id)
  }
  
  public enum NotificationType: String {
    case connection = "Connection"
    case project = "Project"
    case featuredProject = "Featured Project"
  }
}

extension Notification: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.parent(User.self, foreignIdKey: "owner_id")
      db.parent(User.self, foreignIdKey: "user_id")
      db.string("message")
      db.string("type")
      db.int("type_id")
      db.bool("have_read")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

extension Notification: JSONRepresentable {
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set("owner", owner.get()?.makeJSON())
    try json.set("user", user.get()?.makeJSON())
    try json.set("message", message)
    try json.set("type", type)
    try json.set("type_id", type_id)
    try json.set("have_read", have_read)
    try json.set("created_at", createdAt)
    try json.set("updated_at", updatedAt)
    return json
  }
}
