import HTTP
import Vapor

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
    - parameter asset: The Asset Database model used to record the results after a successful save
    - parameter file: A Data URI base64-encoded used to save the image files for us
  */
  func uploadFile(type: ContentType, file: String) throws -> ResponseRepresentable {
    // this will generate the url
    let url = "\(baseUrl)/\(type.rawValue)/upload"
    
    // set up our headers here
    let headers: [HeaderKey: String] = [.contentType: "application/json"]
    
    // set up our body content
    var json = JSON()
    try json.set("file", file)
//    try json.set("api_key", apiKey)
    try json.set("upload_preset", uploadPreset)
//    try json.set("timestamp", Date().timeIntervalSince1970)
    
    // set up the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    
    let response = try EngineClient.factory.respond(to: request)
    
    // if response is successful we can continue
    guard response.status.statusCode >= 200 && response.status.statusCode <= 299 else {
      throw Abort(.badRequest, reason: "Something went wrong with the image!")
    }
    
    // we can now get the json
    guard let json = response.json else {
      throw Abort(.unprocessableEntity, reason: "Could not parse correctly!")
    }
    
    // attempt to create the asset
    let asset = Asset(
      file_type: try json.get("resource_type"),
      url: try json.get("secure_url"),
      file_name: try json.get("public_id"),
      file_size: try json.get("bytes"),
      public_id: try json.get("public_id")
    )
  }
}
