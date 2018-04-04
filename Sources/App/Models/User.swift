//
//  User.swift
//  App
//
//  Created by Liam Goodwin on 2018-01-23.
// 

import Foundation
import Vapor
import FluentProvider
import Validation

final class User: Model, Timestampable {
  let storage: Storage = Storage()

  //MARK: User Table Variables
  var google_id: String
  var email: String
  var name: String
  var picture: String
  var email_verification: Bool
  var description: String
  var role_id: Identifier?
  var location: String
  var phone_number: String
  var experience_and_credentials: String
  var player_id: Int?
  
  //MARK: Initialize User Table
  init(
    google_id: String,
    email: String,
    name: String,
    picture: String,
    email_verification: Bool,
    description: String = "",
    role_id: Identifier? = nil,
    location: String = "",
    phone_number: String = "",
    experience_and_credentials: String = "",
    player_id: Int? = nil
  ) throws {
    // Set our values here
    self.google_id = google_id
    self.email = email
    self.name = name
    self.picture = picture
    self.email_verification = email_verification
    self.description = description.trim()
    self.role_id = role_id
    self.location = location.trim()
    self.phone_number = phone_number.trim()
    self.experience_and_credentials = experience_and_credentials.trim()
    self.player_id = player_id
  }
  
  //MARK: Initialize Row
  init(row: Row) throws {
    google_id = try row.get("google_id")
    email = try row.get("email")
    name = try row.get("name")
    picture = try row.get("picture")
    email_verification = try row.get("email_verification")
    description = try row.get("description")
    role_id = try row.get("role_id")
    location = try row.get("location")
    phone_number = try row.get("phone_number")
    experience_and_credentials = try row.get("experience_and_credentials")
    player_id = try row.get("player_id")
  }
  
  //MARK: Make Row
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("google_id", google_id)
    try row.set("email", email)
    try row.set("name", name)
    try row.set("picture", picture)
    try row.set("email_verification", email_verification)
    try row.set("description", description)
    try row.set("role_id", role_id)
    try row.set("location", location)
    try row.set("phone_number", phone_number)
    try row.set("experience_and_credentials", experience_and_credentials)
    try row.set("player_id", player_id)
    
    return row
  }
}

//MARK: User Database Extension
extension User: Preparation {
  
  //MARK: User Prepare
  static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.string("google_id")
      db.string("email")
      db.string("name")
      db.string("picture")
      db.bool("email_verification")
      db.custom("description", type: "TEXT")
      db.foreignId(for: Role.self, optional: true)
      db.string("location")
      db.string("phone_number")
      db.custom("experience_and_credentials", type: "TEXT")
      db.int("player_id", optional: true)
      
    }
  }
  
  //MARK: User Revert
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

//MARK: User JSON Extension
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
    try json.set("role", role.get()?.makeJSON())
    try json.set("location", location)
    try json.set("phone_number", phone_number)
    try json.set("experience_and_credentials", experience_and_credentials)
    try json.set("player_id", player_id)
    
    return json
  }
}

//MARK: Role ID Parent Extension
extension User {
  var role: Parent<User,Role> {
    return parent(id: role_id)
  }
}
