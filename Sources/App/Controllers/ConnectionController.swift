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
  public init() {}
  
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
    
    // check the connection and make sure that the req header userId
    guard let user_id = request.headers["user_id"]?.int, user_id == invite.invitee_id.int || user_id == invite.inviter_id.int else {
      throw Abort(.forbidden, reason: "You can't view another user's connection!")
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
    
    //Declare the invitee and inviter ids
    guard let invitee_id = connection.invitee_id.int else { throw Abort.badRequest }
    guard let inviter_id = connection.inviter_id.int else { throw Abort.badRequest }
    
    //Check if the user requesting the update is equal to the connection user_id
    if request.headers["user_id"]?.int == invitee_id || request.headers["user_id"]?.int == inviter_id {
      
      guard let accepted = request.json?["accepted"]?.bool else {
        throw Abort.badRequest
      }
      
      //Update accepted
      connection.accepted = accepted
      
      
      //Save the connection
      try connection.save()
      
      //Return connection as JSON
      return try connection.makeJSON()
    } else {
      throw Abort(.forbidden, reason: "You don't have the permissions to update a connection under this user.")
    }
      
}
  
  // Create Connection
  func create(_ request: Request) throws -> ResponseRepresentable {
    
    guard let inviter_id = request.headers["user_id"]?.int, let invitee_id = request.json?["invitee_id"]?.int, let accepted = request.json?["accepted"]?.bool, let message = request.json?["message"]?.string else {
      throw Abort.badRequest
    }
    
    let existingConnection = try Connection
      .makeQuery()
      .or { orGroup in
        try orGroup.and { andGroup in
          try andGroup.filter("inviter_id", inviter_id)
          try andGroup.filter("invitee_id", invitee_id)
        }
        try orGroup.and { andGroup in
          try andGroup.filter("inviter_id", invitee_id)
          try andGroup.filter("invitee_id", inviter_id)
        }
      }.first()
    
    guard existingConnection == nil else {
      throw Abort(.conflict, reason: "An invitation has already been created!")
    }
    
    let connection = Connection(inviter_id: Identifier(inviter_id), invitee_id: Identifier(invitee_id), accepted: accepted, message: message)
  
    try connection.save()
    
    return try connection.makeJSON()
    
  }
  
  func delete(_ request: Request) throws -> ResponseRepresentable {
    
    guard let connection_id = request.parameters["id"]?.int
      else {
        throw Abort.badRequest
    }
    
    //Declare the connection by searching the connection model at the given connection_id
    guard let connection = try Connection.find(connection_id)
      else {
        throw Abort.notFound
    }
    
    // check the connection and make sure that the req header userId
    guard let user_id = request.headers["user_id"]?.int, user_id == connection.invitee_id.int || user_id == connection.inviter_id.int else {
      throw Abort(.forbidden, reason: "You can't delete another user's connection!")
    }
    //Delete the connection
    try connection.delete()

    //Return a JSON confirmation message
    return try JSON(node: ["message": "Connection removed."])
  }
  
  func doesExist(_ request: Request) throws -> ResponseRepresentable {
    
    //Declare the passed ids
    guard let inviter_id = request.parameters["inviter_id"]?.int
      else {
        throw Abort.badRequest
    }
    
    guard let invitee_id = request.headers["invitee_id"]?.int
      else {
        throw Abort.badRequest
    }
    
    //Declare the connection by searching the connection model at the given connection_id
    guard
      let connection = try Connection.makeQuery().filter("inviter_id", inviter_id).and({ try $0.filter("invitee_id", invitee_id) }).first(),
      let alternateConnection = try Connection.makeQuery().filter("inviter_id", invitee_id).and({ try $0.filter("invitee_id", inviter_id) }).first()
      else {
        throw Abort.notFound
    }
    
    if connection.exists {
      return try connection.makeJSON()
    } else if alternateConnection.exists {
      return try alternateConnection.makeJSON()
    }
    
    return try JSON(node: ["message": "No Connection between those users exist."])
    
  }
}
