//
//  AssetController.swift
//  App
//
//  Created by Johnny Nguyen on 2018-01-25.
//

import Foundation
import Vapor
import HTTP
import Multipart

/**
 This Asset Controller controls how assets are being handled, There'll be a different service,
 for actually uploading the required materials, but this is just a handicap of how things will work
*/
final class AssetController {
  
  private let config: Config
  
  init(_ config: Config) {
    self.config = config
  }
  
  /**
    Attempts to create the asset, by first creating the model, then attempting to upload an image
  */
  func create(_ req: Request) throws -> ResponseRepresentable {
    // try to parse the type
    guard let type = req.query?["type"]?.string else {
      throw Abort.badRequest
    }
    
    guard let fileType = CloudinaryService.ContentType(rawValue: type) else {
      throw Abort(.badRequest, reason: "Unsupported file type!")
    }
    
    // attempt to retrieve file
    guard let cloudinary = config["cloudinary"] else {
      throw Abort.serverError
    }
    
    guard
      let projectIcon = req.formData?["projectIcon"]?.bool,
      let projectId = req.formData?["projectId"]?.int,
      let file = req.formData?["file"]?.part
    else {
      throw Abort(.badRequest, reason: "Invalid Parameters")
    }
    
    // check project if exists
    guard let project = try Project.find(projectId) else {
      throw Abort(.notFound, reason: "Could not find project!")
    }

    guard req.headers["user_id"]?.int == project.user_id.int else {
      throw Abort(.forbidden, reason: "You are not the owner of this project!")
    }

    let cloudService = try CloudinaryService(config: cloudinary)

    return try cloudService.uploadFile(type: fileType, file: file, projectIcon: projectIcon, project: project)
  }
  
  /**
   Attempts to delete the asset model from the database, as well as the file on cloudinary
  */
  func delete(_ req: Request) throws -> ResponseRepresentable {
    guard let id = req.parameters["id"]?.int else {
      throw Abort.badRequest
    }

    guard let asset = try Asset.find(id) else {
      throw Abort.notFound
    }
    
    try asset.delete()
    
    return try JSON(node: ["message": "Successfully deleted!"])
  }
}
