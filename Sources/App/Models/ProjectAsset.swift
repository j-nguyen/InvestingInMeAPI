//
//  ProjectAsset.swift
//  InvestingInMeAPIPackageDescription
//
//  Created by Liam Goodwin on 2018-01-24.
//

import Foundation
import Vapor
import FluentProvider

final class ProjectAsset: Model, Timestampable {
  var storage: Storage = Storage()

  //MARK ProjectAsset Table Variables
  var project_id: Int
  var asset_id: Int
  
  //MARK: Initialize ModelAsset Table
  init(project_id: Int, asset_id: Int) {
    self.project_id = project_id
    self.asset_id = asset_id
  }
  
  //MARK: Initialize Row
  required init(row: Row) throws {
    project_id = try row.get("project_id")
    asset_id = try row.get("asset_id")
  }
  
  //MARK: Make Row
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("project_id", project_id)
    try row.set("asset_id", asset_id)
    
    return row
  }
}

//MARK: ProjectAsset Database Extension
extension ProjectAsset: Preparation {
  
  //Prepare ProjectAssset Database
  static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.int("project_id")
      db.int("asset_id")
    }
  }
  
  //Revert ProjectAsset Database
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

extension ProjectAsset: 


