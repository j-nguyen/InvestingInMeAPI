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
    
    //Declare the connection_id requested in the url
    guard let connection_id = request.parameters["id"]?.int
      else {
        throw Abort.badRequest
    }
  
    guard let invite = try Connection.find(connection_id) else {
      throw Abort.notFound
    }
    
    //Return connection as JSON
    return try invite.makeJSON()
    }
  
  //MARK: Update Connection
  func update(_ request: Request) throws -> ResponseRepresentable {
    
    //Declare the connection_id requested in the url
    guard let connection_id = request.parameters["id"]?.int
      else {
        throw Abort.badRequest
    }
    
    //Declare the connection by searching the connection model at the given connection_id
    guard let connection = try Connection.find(connection_id)
      else {
        throw Abort.notFound
    }
    
    guard let accepted = request.json?["accepted"]?.bool else {
      throw Abort.badRequest
    }
    
    //Update accepted
    connection.accepted = accepted
    
    
    //Save the connection
    try connection.save()
    
    //Return connection as JSON
    return try connection.makeJSON()
    
}
  
  // Create Connection
  func create(_ request: Request) throws -> ResponseRepresentable {
    
    guard let inviter_id = request.parameters["inviter_id"]?.int, let invitee_id = request.parameters["invitee_id"]?.int, let accepted = request.parameters["accepted"]?.bool, let message = request.parameters["message"]?.string else {
      throw Abort.badRequest
    }
    
   let connection = Connection(inviter_id: Identifier(inviter_id), invitee_id: Identifier(invitee_id), accepted: accepted, message: message)
    
    try connection.save()
    
    return try connection.makeJSON()
    
  }
}
