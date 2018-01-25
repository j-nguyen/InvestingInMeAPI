//
//  Project.swift
//  App
//
//  Created by Liam Goodwin on 2018-01-24.
//

import Foundation
import Vapor
import FluentProvider

final class Project: Model, Timestampable {
  let storage: Storage = Storage()

  //MARK: Project Table Variables
  var user_id: Int
  var name: String
  var category_id: Identifier
  var role_id: Identifier
  var project_description: String
  var description_needs: String

  //MARK: Initialize Project Table
  init(user_id: Int, name: String, category_id: Identifier, role_id: Identifier, project_description: String, description_needs: String) {
    self.user_id = user_id
    self.name = name
    self.category_id = category_id
    self.role_id = role_id
    self.project_description = project_description
    self.description_needs = description_needs
  }
  
  //MARK: Initialize Row
  init(row: Row) throws {
    user_id = try row.get("user_id")
    name = try row.get("name")
    category_id = try row.get("category_id")
    role_id = try row.get("role_id")
    project_description = try row.get("project_description")
    description_needs = try row.get("description_needs")
  }
  
  //MARK: Make Row
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("user_id", user_id)
    try row.set("name", name)
    try row.set("category_id", category_id)
    try row.set("role_id", role_id)
    try row.set("project_description", project_description)
    try row.set("description_needs", description_needs)
    
    return row
  }
}

//MARK: Project Database Extension
extension Project: Preparation {
  
  //MARK: Project Prepare
  static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.int("user_id")
      db.string("name")
      //db.parent(Category.self)
      db.parent(Role.self)
      db.custom("project_description", type: "TEXT")
      db.custom("description_needs", type: "TEXT")
    }
  }
  
  //MARK: Project Revert
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

//MARK: Project JSON Extension
extension Project: JSONRepresentable {
  func makeJSON() throws -> JSON {
    var json = JSON()
    
    try json.set("id", id)
    try json.set("user_id", user_id)
    try json.set("name", name)
    //try json.set("category", category.get()?.makeJSON())
    try json.set("role", role.get()?.makeJSON())
    try json.set("project_description", project_description)
    try json.set("description_needs", description_needs)
    
    return json
  }
}


