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
  let connectionController = ConnectionController()
  
  func testRoutes() throws {
    guard let id = try createConnection() else {
      XCTFail()
      return
    }
    
    try fetchConnection(id: id)
    try updateConnection(id: id)
    try deleteConnection(id: id)
  }
  
  func fetchConnection(id: Int) throws {
    let request = Request.makeTest(method: .get, headers: ["user_id": "\(1)"])
    request.parameters["id"] = Parameters(id)
    
    let res = try connectionController.show(request)
    let json = try res.makeResponse().json
    
    XCTAssertNotNil(json?["id"])
    XCTAssertNotNil(json?["inviter"])
    XCTAssertNotNil(json?["invitee"])
    XCTAssertNotNil(json?["accepted"])
    XCTAssertNotNil(json?["message"])
  }
  
  func createConnection() throws -> Int? {
    // invitee, message, accepted
    var connection = JSON()
    try connection.set("invitee_id", 2)
    try connection.set("message", "I want to connect with you")
    try connection.set("accepted", false)
    let request = Request.makeTest(method: .post, headers: ["user_id": "\(1)"])
    request.json = connection
    // create connection
    let res = try connectionController.create(request)
    
    try res.makeResponse().assertStatus(is: .ok)
    
    return try res.makeResponse().json?["id"]?.int
  }
  
  func updateConnection(id: Int) throws {
    let json = try JSON(node: ["accepted": true])
    let request = Request.makeTest(method: .patch, headers: ["user_id": "\(1)"])
    request.json = json
    request.parameters["id"] = Parameters(id)
    
    let res = try connectionController.update(request)
    
    try res.makeResponse().assertStatus(is: .ok)
    try XCTAssertNotEqual(res.makeResponse().json?["accepted"]?.bool, false)
  }

  func deleteConnection(id: Int) throws {
    let request = Request.makeTest(method: .delete, headers: ["user_id": "\(1)"])
    request.parameters["id"] = Parameters(id)
    
    let res = try connectionController.delete(request)
    
    try res.makeResponse().assertStatus(is: .ok)
  }
}


extension ConnectionControllerTests {
  static let allTests = [
    ("testRoutes", testRoutes)
  ]
}
