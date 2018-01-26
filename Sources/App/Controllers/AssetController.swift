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
    guard let file = req.json?["file"]?.string else {
      throw Abort.badRequest
    }
    
    // attempt to retrieve file
    guard let config = drop?.config["cloudinary"] else {
      throw Abort.serverError
    }
    
    let asset = Asset(file_type: "image", url: "sdf", file_name: "sdf", file_size: 23)
    
    let cloudService = try CloudinaryService(config: config)
    try cloudService.uploadFile(type: .image, asset: asset, file: file)
    
    return Response(status: .ok)
  }
}
