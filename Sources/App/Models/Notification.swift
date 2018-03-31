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
  var message: String
  var type: String
  var type_id: Int
  
  init(user_id: Identifier, message: String, type: String, type_id: Int) {
    self.user_id = user_id
    self.message = message
    self.type = type
    self.type_id = type_id
  }
  
  init(row: Row) throws {
    user_id = try row.get("row_id")
    message = try row.get("message")
    type = try row.get("type")
    type_id = try row.get("type_id")
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("user_id", user_id)
    try row.set("message", message)
    try row.set("type", type)
    try row.set("type_id", type_id)
    return row
  }
}

extension Notification {
  var user: Parent<Notification, User> {
    return parent(id: user_id)
  }
}

extension Notification: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.parent(User.self)
      db.string("message")
      db.string("type")
      db.int("type_id")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

extension Notification: JSONRepresentable {
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set("user", user.get()?.makeJSON())
    try json.set("message", message)
    try json.set("type", type)
    try json.set("type_id", type_id)
    return json
  }
}
