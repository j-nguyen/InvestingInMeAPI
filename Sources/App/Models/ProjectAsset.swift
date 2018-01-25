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
  
  init(row: Row) throws {
    <#code#>
  }
  
  func makeRow() throws -> Row {
    <#code#>
  }
  
  
}
