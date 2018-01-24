//
//  Connection.swift
//  App
//
//  Created by Johnny Nguyen on 2018-01-24.
//

import Foundation
import Vapor
import FluentProvider

final class Connection: Model, Timestampable {
  // MARK: Properties
  var inviter_id: Identifier
  var invitee_id: Identifier
  var accepted: Bool
  var message: String
  
  let storage: Storage = Storage()
  
  // MARK: Initializing the Conneciton
  
  /**
   Creates a connection model.
   
   - Parameters:
      - inviter_id: The host, the person who invited.
      - invitee_id: The user that's being invited.
      - accepted: Checks if the user accepted the invite. By default, it's false
      - message: a message sent to the user about their request
  */
  init(inviter_id: Identifier, invitee_id: Identifier, accepted: Bool = false, message: String) {
    self.inviter_id = inviter_id
    self.invitee_id = invitee_id
    self.accepted = accepted
    self.message = message
  }
  
  // MARK: Used for rows, and connecting to the database
  
  init(row: Row) throws {
    inviter_id = try row.get("inviter_id")
    invitee_id = try row.get("invitee_id")
    accepted = try row.get("accepted")
    message = try row.get("message")
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("inviter_id", inviter_id)
    try row.set("invitee_id", invitee_id)
    try row.set("accepted", accepted)
    try row.set("message", message)
    return row
  }
}
