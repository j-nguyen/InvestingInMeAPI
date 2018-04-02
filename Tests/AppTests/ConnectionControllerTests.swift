//
//  ConnectionControllerTests.swift
//  AppTests
//
//  Created by Johnny Nguyen on 2018-02-02.
//

import XCTest
import Foundation
import Testing
import HTTP
import Random
@testable import Vapor
@testable import App

class ConnectionControllerTests: TestCase {
  let drop = try! Droplet.testable()
  let connectionController = ConnectionController()
  let user = try! User.makeQuery().filter("email", "fakeuser@example.com").first()!
  let otherUser = try! User.makeQuery().filter("email", "fakeuser2@example.com").first()!
  
  var existedConnection: Connection!
  
  func testCreateConnection() throws {
    var connection = JSON()
    // invitee, message, accepted
    try connection.set("invitee_id", otherUser.id!.int)
    try connection.set("message", "I want to connect with you")
    try connection.set("accepted", false)
    let request = Request.makeTest(method: .post, headers: ["user_id": "\(user.id!.int!)"])
    request.json = connection
    // create connection
    let json = try connectionController.create(request)
    try json.makeResponse().assertStatus(is: .ok)

    existedConnection = try Connection.makeQuery()
      .filter("inviter_id", user.id)
      .filter("invitee_id", otherUser.id)
      .first()!
  }
  
//  func testUpdateConnection() throws {
//    // set up the connection here
//    let connection: Connection
//    if try Connection.makeQuery().filter("inviter_id", user.assertExists()).first() == nil {
//      connection = try Connection(inviter_id: user.assertExists(), invitee_id: otherUser.assertExists(), accepted: true, message: "I want to connect with you")
//      try connection.save()
//    } else {
//      connection = try Connection.makeQuery().filter("inviter_id", user.assertExists()).first()!
//    }
//
//    // make sure it's not
//    XCTAssertNotNil(connection)
//
//    // update the connnection and make sure it's not the same
//    let tmpMessage = connection.message
//    connection.message = "Hey buddy, I want to connect with ya"
//    try connection.save()
//
//    XCTAssertNotEqual(tmpMessage, connection.message)
//  }
//
//  func testDeleteConnection() throws {
//    try Connection.makeQuery().delete()
//
//    XCTAssertEqual(0, try Connection.count())
//  }
}


extension ConnectionControllerTests {
  static let allTests = [
    ("testCreateConnection", testCreateConnection),
//    ("testUpdateConnection", testUpdateConnection),
//    ("testDeleteConnection", testDeleteConnection)
  ]
}
