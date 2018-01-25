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
  
  // Our base url to create
  private static let baseUrl: String = "https://api.cloudinary.com/v1_1/dvrolb5ai"
  
  // MARK: Enums
  enum ContentType {
    case image
    case video
  }
  
  /**
    Intializer used to set up how the api and api secret key looks
 
    - parameter apiKey: The Api Key Token String for us we need in our url parameters
    - parameter apiSecret: The Secret we need to enter in our headers
  */
  init(apiKey: String, apiSecret: String) {
    self.apiKey = apiKey
    self.apiSecret = apiSecret
  }
  
  /**
    This convenience initializer is used so that we can use the keys set-up. If you prefer not to, then
    you can use the above method to get an idea and feel.
   
    - parameter config: Our Config file set-up
  */
  convenience init(config: Config) throws {
    try self.init(
      apiKey: config.get("apiKey"),
      apiSecret: config.get("apiSecret")
    )
  }
  
  /**
    Attempts to upload the file based on the content type chosen
   
    - parameter type: The file type of its used
    - parameter fileName: The name of the file string
  */
  func uploadFile(type: ContentType, fileName: String) {
    
  }
}
