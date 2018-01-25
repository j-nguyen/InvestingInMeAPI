//
//  ConnectionController.swift
//  App
//
//  Created by jarrod maeckeler on 2018-01-25.
//

import Foundation
import Vapor
import HTTP

final class ConnectionController {
  
  //MARK: Show Connection Invite
  func show(_ request: Request) throws -> ResponseRepresentable {
    
    //Declare the user_id requested in the url
    guard let connection_id = request.parameters["id"]?.int
      else {
        throw Abort.badRequest
    }
  
    guard let invite = try Connection.find(connection_id) else {
      throw Abort.notFound
    }
    
    //Return user as JSON
    return try invite.makeJSON()
    }
  
  //MARK: Update User
  func update(_ request: Request) throws -> ResponseRepresentable {
    
    //Declare the user_id requested in the url
    guard let connection_id = request.parameters["id"]?.int
      else {
        throw Abort.badRequest
    }
    
    //Declare the user by searching the User model at the given user_id
    guard let connection = try Connection.find(connection_id)
      else {
        throw Abort.notFound
    }
    
    guard let accepted = request.json?["accepted"]?.bool else {
      throw Abort.badRequest
    }
    
    //Update accepted
    connection.accepted = accepted
    
    
    //Save the user
    try connection.save()
    
    //Return user as JSON
    return try connection.makeJSON()
    
}
}
