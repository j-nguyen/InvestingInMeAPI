//
//  AlterPlayerIdUser.swift
//  App
//
//  Created by Johnny Nguyen on 2018-04-05.
//

import Foundation
import Vapor
import FluentProvider

struct AlterPlayerIdUser: Preparation {
  static func prepare(_ database: Database) throws {
    try database.modify(User.self) { db in
      db.delete("player_id")
      db.string("player_id", optional: true)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.modify(User.self) { db in
      db.int("player_id", optional: true)
    }
  }
}
