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
  
  // MARK: Properties
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

// MARK: Category Conveience operators
extension Category {
  enum Group: String {
    case game = "Game"
    case mobileApp = "Mobile App"
    case mobileGameApp = "Mobile Game App"
    case website = "Website"
    case desktop = "Desktop App"
    case other = "Other"
    
    /**
      Attempts to find a category, by searching for the enum list at the above top.
    */
    func category() throws -> Category {
      guard let category = try Category.makeQuery().filter("type", rawValue).first() else {
        throw Abort.notFound
      }
      
      return category
    }

    // constant values
    static let allValues: [String] = [
      Group.game.rawValue, Group.mobileApp.rawValue, Group.mobileGameApp.rawValue,
      Group.website.rawValue, Group.desktop.rawValue, Group.other.rawValue
    ]
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
