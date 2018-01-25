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
    guard let id = request.parameters["id"]?.int
      else {
        throw Abort.badRequest
    }
  
    guard let invite = try Connection.find(id) else {
      throw Abort.notFound
    }
    
    //Return user as JSON
    return try invite.makeJSON()
    }
  
  
    
}
