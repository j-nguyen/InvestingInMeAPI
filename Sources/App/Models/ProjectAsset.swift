//
//  ProjectAsset.swift
//  InvestingInMeAPIPackageDescription
//
//  Created by Liam Goodwin on 2018-01-24.
//

import Foundation
import Vapor
import FluentProvider

final class AssetModel: Model, Timestampable {
  var storage: Storage = Storage()

  //MARK ProjectAsset Table Variables
  var project_id: Identifier
  var asset_id: Identifier
  
  //MARK: Initialize ModelAsset Table
  init(project_id: Identifier, asset_id: Identifier) {
    self.project_id = project_id
    self.asset_id = asset_id
  }
  
  //MARK: Initialize Row
  init(row: Row) throws {
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


