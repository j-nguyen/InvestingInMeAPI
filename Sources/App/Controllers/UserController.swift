//
//  UserController.swift
//  App
//
//  Created by Liam Goodwin on 2018-01-25.
//
import Foundation
import Vapor
import HTTP
import JWT
import Validation

final class UserController {
  
  private let config: Config
  
  init(_ config: Config) {
    self.config = config
  }
  
  //MARK: Show User
  func show(_ request: Request) throws -> ResponseRepresentable {
    
    //Declare the user_id requested in the url
    guard let user_id = request.parameters["id"]?.int
      else {
        throw Abort.badRequest
    }
    
    //Declare the user by searching the User model at the given user_id
    guard let user = try User.find(user_id)
      else {
        throw Abort.notFound
    }
    
    //Return user as JSON
    return try user.makeJSON()
  }
  
  //MARK: Create Project
  func createProject(_ request: Request) throws -> ResponseRepresentable {
    
    //Pull the values from the request for each column
    guard
      let user_id = request.json?["user_id"]?.int,
      let name = request.json?["name"]?.string,
      let category_id = request.json?["category_id"]?.int,
      let role_id = request.json?["role_id"]?.int,
      let project_description = request.json?["project_description"]?.string,
      let description_needs = request.json?["description_needs"]?.string
    else {
      throw Abort(.badRequest, reason: "Missing required fields!")
    }
    
    //Check if the user_id in the authorization header is the user_id of the project
    guard request.headers["user_id"]?.int == user_id else {
      throw Abort(.forbidden, reason: "You don't have the permissions to create a project under this user.")
    }
    
    // Check if the category exists
    guard try Category.find(category_id) != nil else {
      throw Abort(.notFound, reason: "This category doesn't exist!")
    }
    
    // Check if role exists
    guard try Role.find(role_id) != nil else {
      throw Abort(.notFound, reason: "This role doesn't exist!")
    }
    
    // Check for profanity
    // Check for word filter
    let filterWordService = try FilterWordService(forPath: "\(config.workDir)badwords.txt")
    
    // Check for multiple profanities
    guard !filterWordService.isBadWord(forContent: name) else {
      throw Abort(.badRequest, reason: "Your name contains profanity!")
    }
    
    guard !filterWordService.isBadWord(forContent: project_description) else {
      throw Abort(.badRequest, reason: "Your project description contains profanity!")
    }
    
    guard !filterWordService.isBadWord(forContent: description_needs) else {
      throw Abort(.badRequest, reason: "Your description needs contains profanity!")
    }
    
    //Instaniate the project using the variables we created
    let project = try Project(
      user_id: Identifier(user_id),
      name: name,
      category_id: Identifier(category_id),
      role_id: Identifier(role_id),
      project_description: project_description,
      description_needs: description_needs
    )
    
    // Save the new project
    try project.save()
    
    // save the asset
    let projectIconAsset = try Asset(
      project_id: project.assertExists(),
      file_type: CloudinaryService.ContentType.image.rawValue,
      url: project.name.generatePlaceholder(),
      file_name: "placeholder",
      file_size: 0,
      project_icon: true
    )
    
    try projectIconAsset.save()
    
    //Return the newly created project
    return try project.makeJSON()
  }
  
  //MARK Show all Projects at User
  func userProjects(_ request: Request) throws -> ResponseRepresentable {
    
    //Declare the user_id requested in the url
    guard let user_id = request.parameters["id"]?.int
      else {
        throw Abort.badRequest
    }
    
    //Return all projects at the specified user_id
    return try Project.makeQuery().filter("user_id", user_id).all().makeJSON()
  }
  
  //MARK: Shows all connection from that user
  func connection(_ req: Request) throws -> ResponseRepresentable {
    guard let id = req.parameters["id"]?.int else {
      throw Abort.badRequest
    }
    
    // check to make sure that user is you
    guard req.headers["user_id"]?.int == id else {
      throw Abort(.forbidden, reason: "You can only view your own connections!")
    }
    
    let connection = try Connection.makeQuery()
      .or { orGroup in
        try orGroup.filter("inviter_id", id)
        try orGroup.filter("invitee_id", id)
      }
      .all()
    
    if let connectionId = req.query?["connection_id"]?.int {
      guard let existingConnection = try Connection
        .makeQuery()
        .or({ orGroup in
          try orGroup.and { andGroup in
            try andGroup.filter("inviter_id", id)
            try andGroup.filter("invitee_id", connectionId)
          }
          try orGroup.and { andGroup in
            try andGroup.filter("inviter_id", connectionId)
            try andGroup.filter("invitee_id", id)
          }
        }).first() else {
          throw Abort(.notFound, reason: "Could not find connection!")
      }
      return try existingConnection.makeJSON()
    }
    
    return try connection.makeJSON()
  }
  
  //MARK: Update User
  func update(_ request: Request) throws -> ResponseRepresentable {
    
    //Declare the user_id requested in the url
    guard let user_id = request.parameters["id"]?.int, let myUserId = request.headers["user_id"]?.int else {
      throw Abort.badRequest
    }
    
    guard user_id == myUserId else {
      throw Abort(.forbidden, reason: "You are not the user of this!")
    }
    
    //Declare the user by searching the User model at the given user_id
    guard let user = try User.find(user_id) else {
      throw Abort.notFound
    }
    
    // Check for profanity
    // Check for word filter
    guard let dirPath = drop?.config.workDir else {
      throw Abort.serverError
    }
    let filterWordService = try FilterWordService(forPath: "\(dirPath)badwords.txt")
    
    //Update description, and experience_and_credentials if they have been passed through the url
    if let description = request.json?["description"]?.string {
      if !description.isEmpty {
        try CustomASCIIValidator().validate(description)
        guard !filterWordService.isBadWord(forContent: description) else {
          throw Abort(.badRequest, reason: "Your description contains profanity!")
        }
      }
      user.description = description
    }
    
    if let experience_and_credentials = request.json?["experience_and_credentials"]?.string {
      if !experience_and_credentials.isEmpty {
        try CustomASCIIValidator().validate(experience_and_credentials)
        guard !filterWordService.isBadWord(forContent: experience_and_credentials) else {
          throw Abort(.badRequest, reason: "Your experience and credentials contains profanity!")
        }
      }
      user.experience_and_credentials = experience_and_credentials
    }
    
    if let location = request.json?["location"]?.string {
      if !location.isEmpty {
        try CustomASCIIValidator().validate(location)
        guard !filterWordService.isBadWord(forContent: location) else {
          throw Abort(.badRequest, reason: "Your location contains profanity!")
        }
      }
      user.location = location
    }
    
    if let phone_number = request.json?["phone_number"]?.string {
      if !phone_number.isEmpty {
        try OnlyPhoneNumberValidator().validate(phone_number)
      }
        user.phone_number = phone_number
    }
    
    //Update role_id if it has been passed through the url
    if let role_id = request.json?["role_id"]?.int {
      user.role_id = Identifier(role_id)
    }
    
    user.player_id = request.json?["player_id"]?.string 
    
    //Save the user
    try user.save()
    
    //Return user as JSON
    return try user.makeJSON()
  }
  
  func login(_ request: Request) throws -> ResponseRepresentable {
    // check for authorization token in the header
    guard let token = request.json?["token"]?.string else {
      throw Abort(.notFound, reason: "Token not found or invalid.")
    }
    
    let jwt = try JWT(token: token)
    
    // find the right key to test
    guard let keys = try GoogleService.getJWTKeys(token: jwt)
      else {
        throw Abort.serverError
    }
    
    // verify that our signatures are right
    guard let _ = try? jwt.verifySignature(using: RS256(rsaKey: RSAKey(n: keys.n, e: keys.e)))
      else {
        throw Abort.serverError
    }
    
    // makes sure our clients match
    guard let aud = jwt.payload["aud"]?.string, let client_id = drop?.config["google", "client_id"]?.string, aud == client_id else
    {
      throw Abort(.unauthorized, reason: "Invalid login credentials.")
    }
    
    // make sure the issuer sets up on google
    guard let iss = jwt.payload["iss"]?.string, iss == "https://accounts.google.com" else {
      throw Abort(.unauthorized, reason: "Invalid login credentials.")
    }
    
    // check for expiration
    guard let exp = jwt.payload["exp"]?.int, TimeInterval(exp) > Date().timeIntervalSince1970 else {
      throw Abort(.unauthorized, reason: "Expired Token, please re-login")
    }
    
    // check for the sub and make sure that there's a user existing
    guard let sub = jwt.payload["sub"]?.string else {
      throw Abort(.unprocessableEntity, reason: "Could not find your user data!")
    }
    
    // create a payload for the jwt to add in, this is set to expire in a day
    var payload = JSON(ExpirationTimeClaim(createTimestamp: { Int(Date().timeIntervalSince1970) + 86400 }))
    
    // if it doesn't exist, we'll attempt to make one
    if let user = try User.makeQuery().filter("google_id", sub).first() {
      try payload.set("user_id", user.id)
    } else {
      let user = try User(
        google_id: sub,
        email: try jwt.payload.get("email"),
        name: try jwt.payload.get("name"),
        picture: try jwt.payload.get("picture"),
        email_verification: try jwt.payload.get("email_verified")
      )
      
      try user.save()
      
      try payload.set("user_id", user.id)
    }
    
    // Grab generated random string to try to get it
    guard let login = config["login", "key"]?.string else { throw Abort.serverError }
    
    let authToken = try JWT(payload: payload, signer: HS512(key: login.bytes))
    
    return try JSON(node: ["token": authToken.createToken()])
  }
  
  //Return all roles to allow the user to select a new role
  func roles(_ request: Request) throws -> ResponseRepresentable {
    
    //Return all roles in JSON format
    return try Role.all().makeJSON()
  }
  
}
