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
  
  func show(_ request: Request) throws -> ResponseRepresentable {
    
    //Declare the user_id requested in the url, and ensure it is an integer
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
  
}
