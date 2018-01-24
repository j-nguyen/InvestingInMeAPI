//
//  User.swift
//  App
//
//  Created by Liam Goodwin on 2018-01-23.
//

import Foundation
import Vapor
import FluentProvider

final class User: Model, Timestampable {
  let storage: Storage = Storage()

  //MARK: Properties
  var google_id: Int
  var email: String
  var name: String
  var picture: String
  var email_verification: Bool
  var description: String
  var location: String
  var phone_number: String
  var experience_and_credentials: String
  var player_id: Int
  
  init(google_id: Int, email: String, name: String, picture: String, email_verification: Bool,
       description: String, location: String, phone_number: String, experience_and_credentials: String, player_id: Int) {
    self.google_id = google_id
    self.email = email
    self.name = name
    self.picture = picture
    self.email_verification = email_verification
    self.description = description
    self.location = location
    self.phone_number = phone_number
    self.experience_and_credentials = experience_and_credentials
    self.player_id = player_id
  }
  
  init(row: Row) throws {
    google_id = try row.get("google_id")
    email = try row.get("email")
    name = try row.get("name")
    picture = try row.get("picture")
    email_verification = try row.get("email_verification")
    description = try row.get("description")
    location = try row.get("location")
    phone_number = try row.get("phone_number")
    experience_and_credentials = try row.get("experience_and_credentials")
    player_id = try row.get("player_id")
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("google_id", google_id)
    try row.set("email", email)
    try row.set("name", name)
    try row.set("picture", picture)
    try row.set("email_verification", email_verification)
    try row.set("description", description)
    try row.set("location", location)
    try row.set("phone_number", phone_number)
    try row.set("experience_and_credentials", experience_and_credentials)
    try row.set("player_id", player_id)
    
    return row
  }
  
}

extension User: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.int("google_id")
      db.string("email")
      db.string("name")
      db.string("picture")
      db.bool("email_verification")
      db.custom("description", type: "TEXT")
      db.string("location")
      db.string("phone_number")
      db.custom("experience_and_credentials", type: "TEXT")
      db.int("player_id")
      
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

extension User: JSONRepresentable {
  func makeJSON() throws -> JSON {
    var json = JSON()
    
    try json.set("id", id)
    try json.set("google_id", google_id)
    try json.set("email", email)
    try json.set("name", name)
    try json.set("picture", picture)
    try json.set("email_verification", email_verification)
    try json.set("description", description)
    try json.set("location", location)
    try json.set("phone_number", phone_number)
    try json.set("experience_and_credentials", experience_and_credentials)
    try json.set("player_id", player_id)
    
    return json
  }
}
