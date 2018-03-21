import HTTP
import Vapor
import Foundation
import Multipart

/**
 Our CloudinaryService is the service for actually using the Restful API connection to ensure that we've
 made progress and response
*/
final class CloudinaryService {
  // MARK: Properties
  private let apiKey: String
  private let apiSecret: String
  private let uploadPreset: String
  
  // Our base url to create
  private let baseUrl: String = "https://api.cloudinary.com/v1_1/dvrolb5ai"
  
  // MARK: Enums
  enum ContentType: String {
    case image
    case video
  }
  
  /**
    Intializer used to set up how the api and api secret key looks
 
    - parameter apiKey: The Api Key Token String for us we need in our url parameters
    - parameter apiSecret: The Secret we need to enter in our headers
    - parameter uploadPreset: The contents of which the metadata gets stored
  */
  init(apiKey: String, apiSecret: String, uploadPreset: String) {
    self.apiKey = apiKey
    self.apiSecret = apiSecret
    self.uploadPreset = uploadPreset
  }
  
  /**
    This convenience initializer is used so that we can use the keys set-up. If you prefer not to, then
    you can use the above method to get an idea and feel.
   
    - parameter config: Our Config file set-up
  */
  convenience init(config: Config) throws {
    try self.init(
      apiKey: config.get("apiKey"),
      apiSecret: config.get("apiSecret"),
      uploadPreset: config.get("uploadPreset")
    )
  }
  
  /**
    Attempts to upload the file based on the content type chosen
   
    - parameter type: The file type of its used
    - parameter file: A Data URI base64-encoded used to save the image files for us
    - parameter projectIcon: This asks to make sure it's a profileIcon or not
    - parameter project: The project model so that we can insert it into our asset model
  */
  func uploadFile(type: ContentType, file: String, projectIcon: Bool, project: Project) throws -> ResponseRepresentable {
    // this will generate the url
    let url = "\(baseUrl)/\(type.rawValue)/upload"
    
    // set up our headers here
    let headers: [HeaderKey: String] = [.contentType: "application/json"]
    // set up our body content
    var json = JSON()
    try json.set("file", "data:image/png;base64,\(file)")
    try json.set("upload_preset", uploadPreset)
    
    // set up the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    let response = try EngineClient.factory.respond(to: request)
    // if response is successful we can continue
    guard response.status.statusCode >= 200 && response.status.statusCode <= 299 else {
      throw Abort(.badRequest, reason: "Something went wrong with the image!")
    }
    
    // we can now get the json
    guard let responseJSON = response.json else {
      throw Abort(.unprocessableEntity, reason: "Could not parse correctly!")
    }
    
    // attempt to create the asset
    if let asset = try Asset.makeQuery().filter("project_id", project.id).and({ try $0.filter("projectIcon", true) }).first() {
      try asset.file_type = responseJSON.get("resource_type")
      try asset.url = responseJSON.get("secure_url")
      try asset.file_name = responseJSON.get("public_id")
      try asset.file_size = responseJSON.get("bytes")
      try asset.public_id = responseJSON.get("public_id")
      // attempt to save once finished
      try asset.save()
      
      return try asset.makeJSON()
    } else {
      let asset = try Asset(
        project_id: project.assertExists(),
        file_type: responseJSON.get("resource_type"),
        url: responseJSON.get("secure_url"),
        file_name: responseJSON.get("public_id"),
        file_size: responseJSON.get("bytes"),
        project_icon: projectIcon,
        public_id: responseJSON.get("public_id")
      )
      
      // attempt to save once finished
      try asset.save()
      
      return try asset.makeJSON()
    }
  }
  
  /**
   Attempts to upload the file based on the content type chosen
   
     - parameter type: The file type of its used
     - parameter file: String
     - parameter project: The project model needed to upload with asset to create a relation
   */
  func uploadFile(type: ContentType, file: Bytes, project: Project) throws -> ResponseRepresentable {
    // this will generate the url
    let url = "\(baseUrl)/\(type.rawValue)/upload"
    
    // set up our headers here
    let headers: [HeaderKey: String] = [.contentType: "application/json"]

    let json = try JSON(node: [
      "file": "data:video/mp4;base64,\(file.base64Encoded.makeString())",
      "upload_preset": uploadPreset
    ])
    
    // set up the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    
    let response = try EngineClient.factory.respond(to: request)
    
    // if response is successful we can continue
    guard response.status.statusCode >= 200 && response.status.statusCode <= 299 else {
      throw Abort(.badRequest, reason: "Something went wrong with the file!")
    }
    
    // we can now get the json
    guard let responseJSON = response.json else {
      throw Abort(.unprocessableEntity, reason: "Could not parse correctly!")
    }
    
    // attempt to create the asset
    let asset = try Asset(
      project_id: project.assertExists(),
      file_type: responseJSON.get("resource_type"),
      url: responseJSON.get("secure_url"),
      file_name: responseJSON.get("public_id"),
      file_size: responseJSON.get("bytes"),
      project_icon: false,
      public_id: responseJSON.get("public_id")
    )
    
    // attempt to save once finished
    try asset.save()
    
    return try asset.makeJSON()
  }
  
  /**
   This will attempt to delete the file, based on the id given, which is the unique identifier
   
   - parameter type: The resource type of which type of image or video it is.
   - parameter asset: The asset model from the database
  */
  func deleteFile(type: ContentType, asset: Asset) throws {
    // generate the url once again
    let url = "\(baseUrl)/\(type.rawValue)/destroy"
    
    // create the headers
    let headers: [HeaderKey: String] = [.contentType: "application/json"]
    
    // setup hash
    let timestamp = Int(Date().timeIntervalSince1970)
    let hash = CryptoHasher(hash: .sha1, encoding: .hex)
    let encrypt: String = ["public_id=\(asset.public_id!)", "timestamp=\(timestamp)"].joined(separator: "&") + apiSecret
    let signature = try hash.make(encrypt)
    
    // set up body
    var json = JSON()
    try json.set("public_id", asset.public_id)
    try json.set("timestamp", timestamp)
    try json.set("signature", signature.makeString())
    try json.set("api_key", apiKey)
    
    // set up request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    
    // attempt variable to remove the warning
    _ = try EngineClient.factory.respond(to: request)
  }
}
