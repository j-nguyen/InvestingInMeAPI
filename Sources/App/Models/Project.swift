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
  var storage: Storage

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
  
  
  func makeRow() throws -> Row {
    <#code#>
  }
  
  
}
