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
    // im gonna assume this would be ok for base64 content
    guard let file = req.json?["file"]?.string,
      let projectIcon = req.json?["project_icon"]?.bool else {
      throw Abort.badRequest
    }
    
    // try to parse the type
    guard let type = req.json?["type"]?.string, let fileType = CloudinaryService.ContentType(rawValue: type) else {
      throw Abort(.unprocessableEntity, reason: "Unsupported file type!")
    }
    
    // attempt to retrieve file
    guard let config = drop?.config["cloudinary"] else {
      throw Abort.serverError
    }
    
    let cloudService = try CloudinaryService(config: config)
    
    return try cloudService.uploadFile(type: fileType, file: file, projectIcon: projectIcon)
  }
}
