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
  */
  func uploadFile(type: ContentType, file: String, projectIcon: Bool) throws -> ResponseRepresentable {
    // this will generate the url
    let url = "\(baseUrl)/\(type.rawValue)/upload"
    
    // set up our headers here
    let headers: [HeaderKey: String] = [.contentType: "application/json"]
    
    // set up our body content
    var json = JSON()
    try json.set("file", file)
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
    let asset = Asset(
      file_type: try responseJSON.get("resource_type"),
      url: try responseJSON.get("secure_url"),
      file_name: try responseJSON.get("public_id"),
      file_size: try responseJSON.get("bytes"),
      project_icon: projectIcon,
      public_id: try responseJSON.get("public_id")
    )
    
    // attempt to save once finished
    try asset.save()
    
    return try asset.makeJSON()
  }
  
  /**
   Attempts to upload the file based on the content type chosen
   
     - parameter type: The file type of its used
     - parameter file: Bytes
   */
  func uploadFile(type: ContentType, file: Bytes) throws -> ResponseRepresentable {
    // this will generate the url
    let url = "\(baseUrl)/\(type.rawValue)/upload"
    
    // set up our headers here
    let headers: [HeaderKey: String] = [.contentType: "application/x-www-form-urlencoded"]
    
    // set up the request
    let request = Request(method: .post, uri: url, headers: headers)
    request.formURLEncoded = try Node(node: [
      "file": file.base64Encoded.makeString(),
      "upload_preset": uploadPreset
    ])
    
    print (request.description)
    
    let response = try EngineClient.factory.respond(to: request)
    
    // if response is successful we can continue
    guard response.status.statusCode >= 200 && response.status.statusCode <= 299 else {
      print (response.json)
      throw Abort(.badRequest, reason: "Something went wrong with the file!")
    }
    
    // we can now get the json
    guard let responseJSON = response.json else {
      throw Abort(.unprocessableEntity, reason: "Could not parse correctly!")
    }
    
    // attempt to create the asset
    let asset = Asset(
      file_type: try responseJSON.get("resource_type"),
      url: try responseJSON.get("secure_url"),
      file_name: try responseJSON.get("public_id"),
      file_size: try responseJSON.get("bytes"),
      project_icon: false,
      public_id: try responseJSON.get("public_id")
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
    let encrypt: String = ["public_id=\(asset.public_id)", "timestamp=\(timestamp)"].joined(separator: "&") + apiSecret
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
