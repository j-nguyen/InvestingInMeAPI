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

final class UserController {
  
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
    guard let user_id = request.json?["user_id"]?.int, let name = request.json?["name"]?.string, let category_id = request.json?["category_id"]?.int, let role_id = request.json?["role_id"]?.int, let project_description = request.json?["project_description"]?.string, let description_needs = request.json?["description_needs"]?.string else {
      throw Abort.badRequest
    }
    
    //Instaniate the project using the variables we created
    let project = Project(user_id: Identifier(user_id), name: name, category_id: Identifier(category_id), role_id: Identifier(role_id), project_description: project_description, description_needs: description_needs)
    
    //Save the new project
    try project.save()
    
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
  
  //MARK: Update User
  func update(_ request: Request) throws -> ResponseRepresentable {
    
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
    
    //Update description, and experience_and_credentials if they have been passed through the url
    user.description = request.json?["description"]?.string ?? user.description
    user.experience_and_credentials = request.json?["experience_and_credentials"]?.string ?? user.experience_and_credentials
    
    //Update role_id if it has been passed through the url
    if let role_id = request.json?["role_id"]?.int {
      user.role_id = Identifier(role_id)
    }
    
    //Save the user
    try user.save()
    
    //Return user as JSON
    return try user.makeJSON()
  }
  
  func login(_ request: Request) throws -> ResponseRepresentable {
    // check for authorization token in the header
    guard let token = request.headers["Authorization"]?.string else {
      throw Abort(.notFound, reason: "Authorization header not found or invalid.")
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
    guard let sub = jwt.payload["sub"]?.int else {
      throw Abort(.unprocessableEntity, reason: "Could not find your user data!")
    }
    
    // create a payload for the jwt to add in, this is set to expire in a day
    var payload = JSON(ExpirationTimeClaim(createTimestamp: { Int(Date().timeIntervalSince1970) + 86400 }))
    
    // if it doesn't exist, we'll attempt to make one
    if let user = try User.makeQuery().filter("google_id", sub).first() {
      try payload.set("user_id", user.id)
    } else {
      let user = User(
        google_id: sub,
        email: try jwt.payload.get("email"),
        name: try jwt.payload.get("name"),
        picture: try jwt.payload.get("picture"),
        email_verification: try jwt.payload.get("email_verified")
      )
      
      try user.save()
      
      try payload.set("user_id", user.id)
    }
    
    // not the best way to sign for now, but this is for a developmental purpose standpoint.
    let authToken = try JWT(payload: payload, signer: HS512(key: "login".bytes))
    
    return try JSON(node: ["token": authToken])
  }
  
}
