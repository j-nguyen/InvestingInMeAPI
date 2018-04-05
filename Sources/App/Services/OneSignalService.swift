//
//  OneSignalService.swift
//  InvestingInMeAPIPackageDescription
//
//  Created by Liam Goodwin on 2018-04-03.
// 

import Vapor
import HTTP

/** OneSignalService - Send out notifications to devices **/
public final class OneSignalService {
  private let apiKey: String
  private let appId: String
  
  private let baseUrl: String = "https://onesignal.com/api/v1"

  public init(apiKey: String, appId: String) {
    self.apiKey = apiKey
    self.appId = appId
  }
  
  public convenience init(config: Config) throws {
    self.init(
      apiKey: try config.get("apiKey"),
      appId: try config.get("appId")
    )
  }
  
  /**
   Send notification to a specific user
   - parameters:
   - user: User - User that will receive the notification
   - content: String - The message of the notification
   **/
  public func sendNotification(user: User, content: String) throws {
    
    // Set URL
    let url = "\(baseUrl)/notifications"
    
    // Set up the content JSON
    var message = JSON()
    try message.set("en", content)
    
    // Set up our JSON values
    var json = JSON()
    try json.set("app_id", appId)
    try json.set("include_player_ids", [user.player_id ?? ""])
    try json.set("contents", message.makeJSON())
    
    // Set up the headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    
    // Setup the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    
    // Setup the response
    _ = try EngineClient.factory.respond(to: request)
  }
  
  /**
   Sends a notification to the person who requested to become friends with that user
   - parameters:
   - user: User - List of users to send the notifications to
   - content: String - The content of which the information
   **/
  public func sendBatchNotifications(users: [User], content: String) throws -> ResponseRepresentable {
    
    // Set URL
    let url = "\(baseUrl)/notifications"
    
    // Set up the content JSON
    var message = JSON()
    try message.set("en", content)
    
    // Set up our JSON Values
    // Set a variable for map users
    let deviceTokens: [String] = users.map { $0.player_id ?? "" }
    var json = JSON()
    try json.set("app_id", appId)
    try json.set("include_player_ids", deviceTokens)
    try json.set("contents", message.makeJSON())
    
    // Set up our headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    
    // Setup the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    
    // Setup the response
    let response = try EngineClient.factory.respond(to: request)
    
    if let _ = response.json, response.status.statusCode >= 200 && response.status.statusCode <= 299 {
      return Response(status: .ok)
    } else {
      throw Abort(.badRequest, reason: "Could not send notification")
    }
  }
  
  /**
   Sends a scheduled meetup notification
   - parameters:
   - user: User - Who is receiving the notification
   - date: Date - Date notification will be delivered
   - content: String - Notification content
   **/
  public func sendScheduledNotification(user: User, date: Date, content: String) throws -> ResponseRepresentable {
    
    // Set URL
    let url = "\(baseUrl)/notifications"
    
    // Set up the content JSON
    var message = JSON()
    try message.set("en", content)
    
    // Set up our JSON Values
    var json = JSON()
    try json.set("app_id", appId)
    try json.set("include_player_ids", [user.player_id ?? ""])
    try json.set("send_after", date.dateString)
    try json.set("contents", message.makeJSON())
    
    // Set up our headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    
    // Setup the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    
    // Setup the response
    let response = try EngineClient.factory.respond(to: request)
    
    if let _ = response.json, response.status.statusCode >= 200 && response.status.statusCode <= 299 {
      return Response(status: .ok)
    } else {
      throw Abort(.badRequest, reason: "Could not send notification")
    }
  }
  
  /**
   Sends a batched notification to multiple users
   - parameters:
   - user: User - Users to receive the notification
   - date: Date - The date to schedule the
   - content: String - The message of the notification
   **/
  public func sendBatchedScheduledNotification(users: [User], date: Date, content: String) throws {
    // Set URL
    let url = "\(baseUrl)/notifications"
    
    // Set up the content JSON
    var message = JSON()
    try message.set("en", content)
    
    // Set up our JSON Values
    // Set a variable for users
    let player_ids: [String] = users.map { $0.player_id ?? "" }
    var json = JSON()
    try json.set("app_id", appId)
    try json.set("include_player_ids", player_ids)
    try json.set("send_after", date.dateString)
    try json.set("contents", message.makeJSON())
    
    // Set up our headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    
    // Setup the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    
    // Set up the response
    _ = try EngineClient.factory.respond(to: request)
  }
}
