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
  
  func testCreateConnection() throws {
    let otherUser = try User(
      google_id: URandom().makeInt(),
      email: "fakeuser2@example.com",
      name: "Fake User 2",
      picture: "",
      email_verification: true
    )
    try otherUser.save()
    
    XCTAssertNotNil(otherUser)
    
    let user = try User.makeQuery().filter("email", "fakeuser@example.com").first()!
    
    XCTAssertNotNil(user)
    
    // set up the connection here
    let connection = try Connection(inviter_id: user.assertExists(), invitee_id: otherUser.assertExists(), accepted: true, message: "I want to connect with you")
    try connection.save()
    
    XCTAssertNotNil(connection)
  }
  
  func testUpdateConnection() throws {
    // get the first connection and test
    let connection = try Connection.makeQuery().first()!
    // make sure it's not nil
    XCTAssertNotNil(connection)
    
    // update the connnection and make sure it's not the same
    let tmpMessage = connection.message
    connection.message = "Hey buddy, I want to connect with ya"
    try connection.save()
    
    XCTAssertNotEqual(tmpMessage, connection.message)
  }
}


extension ConnectionControllerTests {
  static let allTests = [
    ("testCreateConnection", testCreateConnection),
    ("testUpdateConnection", testUpdateConnection)
  ]
}
