//
//  Category.swift
//  App
//
//  Created by jarrod maeckeler on 2018-01-24.
//

import Foundation
import Vapor
import FluentProvider

final class Category: Model, Timestampable {
  
  let storage: Storage = Storage()
  
  var type: String
  
  init(type: String) {
    self.type = type
  }
  
  required init(row: Row) throws {
    type = try row.get("type")
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    
    try row.set("type", type)
    
    return row
  }
}

extension Category: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.string("type")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

extension Category: JSONRepresentable {
  func makeJSON() throws -> JSON {
    var json = JSON()
    
    try json.set("id", id)
    try json.set("type", type)
    
    return json
  }
}
