//
//  AddUserIdToNotification.swift
//  App
//
//  Created by Johnny Nguyen on 2018-03-31.
//

import Foundation
import Vapor
import FluentProvider

struct AddUserIdToNotification: Preparation {
  static func prepare(_ database: Database) throws {
    try database.modify(Notification.self) { db in
      db.parent(User.self, foreignIdKey: "owner_id")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.modify(Notification.self) { db in
      db.delete("owner_id")
    }
  }
}
