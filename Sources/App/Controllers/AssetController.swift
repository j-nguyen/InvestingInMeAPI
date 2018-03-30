//
//  AssetController.swift
//  App
//
//  Created by Johnny Nguyen on 2018-01-25.
//

import Foundation
import Vapor
import HTTP

/**
 This Asset Controller controls how assets are being handled, There'll be a different service,
 for actually uploading the required materials, but this is just a handicap of how things will work
*/
final class AssetController {
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
    guard let config = drop?.config["cloudinary"] else {
      throw Abort.serverError
    }
    
    switch fileType {
    case .image:
      guard
        let file = req.json?["file"]?.string,
        let projectIcon = req.json?["projectIcon"]?.bool,
        let project_id = req.json?["project_id"]?.int else {
        throw Abort(.badRequest, reason: "Invalid Parameters")
      }
      
      // check project if exists
      guard let project = try Project.find(project_id) else {
        throw Abort(.notFound, reason: "Could not find project!")
      }
    
      guard req.headers["user_id"]?.int == project.user_id.int else {
        throw Abort(.forbidden, reason: "You are not the owner of this project!")
      }
      
      let cloudService = try CloudinaryService(config: config)
      
      return try cloudService.uploadFile(type: fileType, file: file, projectIcon: projectIcon, project: project)
    case .video:
      guard let file = req.formData?["file"]?.part.body, let project_id = req.formData?["project_id"]?.int else {
        throw Abort.badRequest
      }
      
      // check project if exists
      guard let project = try Project.find(project_id) else {
        throw Abort(.notFound, reason: "Could not find project!")
      }
      
      // set up the service and attempt to uplaod the file
      let cloudService = try CloudinaryService(config: config)
      return try cloudService.uploadFile(type: fileType, file: file, project: project)
    }
    
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
  
  /**
   Delete all assets associated with a given user, used for Project Update
   **/
  func deleteProjectAssets(_ req: Request) throws -> ResponseRepresentable {
    guard let projectId = req.parameters["project_id"]?.int else {
      throw Abort.badRequest
    }
    
    guard let assets = try Asset.all.find(project_id: projectId) else {
      throw Abort.notFound
    }
    
    for asset in assets {
      if !asset.project_icon {
        try asset.delete()
      }
    }
    
    return try JSON(node: ["message": "Assets deleted!"])
  }
}
