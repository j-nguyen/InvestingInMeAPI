//
//  Assets.swift
//  App
//
//  Created by jarrod maeckeler on 2018-01-24.
//

import Foundation
import Vapor
import FluentProvider

final class Asset: Model, Timestampable {
  
  let storage: Storage = Storage()
  
  // MARK: Properties
  var project_id: Identifier
  var file_type: String
  var url: String
  var file_name: String
  var file_size: Int64
  var project_icon: Bool
  var public_id: String?
  
  init(project_id: Identifier, file_type: String, url: String, file_name: String, file_size: Int64, project_icon: Bool = false, public_id: String? = nil) {
    self.project_id = project_id
    self.file_type = file_type
    self.url = url
    self.file_name = file_name
    self.file_size = file_size
    self.project_icon = project_icon
    self.public_id = public_id
  }
  
  required init(row: Row) throws {
    project_id = try row.get("project_id")
    file_type = try row.get("file_type")
    url = try row.get("url")
    file_name = try row.get("file_name")
    file_size = try row.get("file_size")
    project_icon = try row.get("project_icon")
    public_id = try row.get("public_id")
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    
    try row.set("project_id", project_id)
    try row.set("file_type", file_type)
    try row.set("url", url)
    try row.set("file_name", file_name)
    try row.set("file_size", file_size)
    try row.set("project_icon", project_icon)
    try row.set("public_id", public_id)
    
    return row
  }
}

// MARK: Other Convenience operators
extension Asset {
  /// This lifecycle gets called once the asset is about to be deleted. We want to delete the file on the 3rd-party first
  func willDelete() throws {
    if let config = drop?.config["cloudinary"], let type = CloudinaryService.ContentType(rawValue: file_type) {
      let cloudService = try? CloudinaryService(config: config)
      try? cloudService?.deleteFile(type: type, asset: self)
    }
  }
  
  /// project
  var project: Parent<Asset, Project> {
    return parent(id: project_id)
  }
}

extension Asset: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.parent(Project.self)
      db.string("file_type")
      db.string("url")
      db.string("file_name")
      db.custom("file_size", type: "BIGINT")
      db.bool("project_icon", default: false)
      db.string("public_id", optional: true)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

extension Asset: JSONRepresentable {
  func makeJSON() throws -> JSON {
    var json = JSON()
    
    try json.set("id", id)
    try json.set("file_type", file_type)
    try json.set("file_name", file_name)
    try json.set("url", url)
    try json.set("file_size", file_size)
    try json.set("project_icon", project_icon)
    try json.set("public_id", public_id)
    
    return json
  }
}

