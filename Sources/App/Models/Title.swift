//
//  Title.swift
//  App
//
//  Created by jarrod maeckeler on 2018-01-23.
//

import Foundation
import Vapor
import FluentProvider

final class Title: Model, Timestampable {
  let storage: Storage = Storage()
  
  var title: String
  
  init(title: String) {
    self.title = title
  }
  
  required init(row: Row) throws {
    title = try row.get("title")
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    
    try row.set("title", title)
    
    return row
  }
}

extension Title: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.string("title")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

extension Title: JSONRepresentable {
  func makeJSON() throws -> JSON {
    var json = JSON()
    
    try json.set("id", id)
    try json.set("title", title)
    
    return json
  }
}
