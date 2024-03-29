//
//  role.swift
//  App
//
//  Created by jarrod maeckeler on 2018-01-23.
//

import Foundation
import Vapor
import FluentProvider

final class Role: Model, Timestampable {
  let storage: Storage = Storage()
  
  var role: String
  
  init(role: String) {
    self.role = role
  }
  
  required init(row: Row) throws {
    role = try row.get("role")
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    
    try row.set("role", role)
    
    return row
  }
}

extension Role {
  /// list of enums we use
  enum Group: String {
    case developer = "Developer"
    case marketer = "Marketer"
    case investor = "Investor"
    case businessPerson = "Business Person"
    case finance = "Finance"
  
    /// tries to find the specified role by search
    func role() throws -> Role {
      guard let role = try Role.makeQuery().filter("role", rawValue).first() else {
        throw Abort.notFound
      }
      
      return role
    }
    
    static let allValues: [String] = [
      Group.developer.rawValue, Group.marketer.rawValue, Group.investor.rawValue,
      Group.businessPerson.rawValue, Group.finance.rawValue
    ]
  }
}

extension Role: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.string("role")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

extension Role: JSONRepresentable {
  func makeJSON() throws -> JSON {
    var json = JSON()
    
    try json.set("id", id)
    try json.set("role", role)
    
    return json
  }
}
