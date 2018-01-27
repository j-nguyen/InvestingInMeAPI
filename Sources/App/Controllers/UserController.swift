//
//  UserController.swift
//  App
//
//  Created by Liam Goodwin on 2018-01-25.
//

import Foundation
import Vapor
import HTTP

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
  
}
