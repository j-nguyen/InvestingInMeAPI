//
//  FeaturedProject.swift
//  App
//
//  Created by Johnny Nguyen on 2018-01-24.
//

import Foundation
import Vapor
import FluentProvider

final class FeaturedProject: Model, Timestampable {
  // MARK: Properties
  var project_id: Identifier
  var duration: Int64
  let storage: Storage = Storage()
  
  /**
    Creates our featured project model, based on the parameters given
    - Parameters
      - project_id: The identifier needed for the relationship between a featured project and a normal project
      - duration: The amount of time that the featured project is going to be on for
   */
  init(project_id: Identifier, duration: Int64) {
    self.project_id = project_id
    self.duration = duration
  }
  
  // MARK: Row Properties used for connecting with the columns on the table
  init(row: Row) throws {
    project_id = try row.get("project_id")
    duration = try row.get("duration")
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("project_id", project_id)
    try row.set("duration", duration)
    return row
  }
}

// MARK: Convenience operators for our project
extension FeaturedProject {
  var project: Parent<FeaturedProject, Project> {
    return parent(id: project_id)
  }
}

// MARK: Prepare Database
extension FeaturedProject: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.parent(Project.self)
      db.int("duration")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

// MARK: JSONRepresentable
extension FeaturedProject: JSONRepresentable {
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set("id", id)
    try json.set("project", project.get()?.makeJSON())
    try json.set("duration", duration)
    return json
  }
}
