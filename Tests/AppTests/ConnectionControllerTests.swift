//
//  ConnectionControllerTests.swift
//  App
//
//  Created by jarrod maeckeler on 2018-01-25.
//

import Vapor
import XCTest
import HTTP
import Sockets

@testable import Vapor
@testable import App

class ConnectionControllerTests: TestCase {

    let drop = try! Droplet.testable()
    
    func testThatUserListIsReturned() throws {
      
      /// MARK: TESTING
      let req = Request(method: .get, uri: "/user/list")
      let res = try drop.testResponse(to: req)
      
      // response is 200
      res.assertStatus(is: .ok)
      
      // test response is json
      guard let json = res.json else {
        
        XCTFail("Error getting json from response from \(res)")
        return
      }
      
      // test json is array
      guard json.array != nil else {
        
        XCTFail("Error expected response to be array")
        return
      }
    }
    
    func testThatConnectionGetsCreated() throws {
      
      /// MARK: PREPARING
      let inviter_id = 1, invitee_id = 2, accepted = true, message = "Hellllllooooo"
      let user = Connection(inviter_id: inviter_id, invitee_id: invitee_id, accepted: accepted, message: message)
      
      let json = try user.makeJSON()
      let reqBody = try Body(json)
      
      /// MARK: TESTING
      let req = Request(method: .post)
      req.json = try JSON(node: ["content": initialMessage])
      let res = try drop.testResponse(to: req)
      
      // response is 200
      res.assertStatus(is: .ok)
      
      // test response is json
      guard let resJson = res.json else {
        
        XCTFail("Error getting json from res: \(res)")
        return
      }
      
      try res.assertJSON("id", passes: { jsonVal in jsonVal.int != nil })
      try res.assertJSON("username", equals: un)
      try res.assertJSON("age", equals: age)
      
      /// MARK: CLEANUP
      guard let userId = resJson["id"]?.int, let userToDelete = try User.find(userId) else {
        
        XCTFail("Error could not convert id to int OR could not find user with id from response: \(res)")
        return
      }
      
      try userToDelete.delete()
    }
    
    func testThatUserGetsReturned() throws {
      
      /// MARK: PREPARING
      let un = "Elon", age = 31
      let user = User(username: un, age: age)
      try user.save()
      
      guard let userId = user.id?.int else {
        
        XCTFail("Error converting user id to int")
        return
      }
      
      /// MARK: TESTING
      let req = Request(method: .get, uri: "/user/\(userId)")
      let res = try drop.testResponse(to: req)
      
      res.assertStatus(is: .ok)
      try res.assertJSON("username", equals: un)
      
      /// MARK: CLEANUP
      try user.delete()
    }
    
    func testThatUserGetsUpdated() throws {
      
      /// MARK: PREPARING
      let un = "Steve", age = 37
      let user = User(username: un, age: age)
      try user.save()
      
      /// MARK: TESTING
      guard let userId = user.id?.int else {
        
        XCTFail("Error converting user id to int")
        return
      }
      
      // change data
      let newUn = "Craig"
      user.username = newUn
      
      let json = try user.makeJSON()
      let reqBody = try Body(json)
      
      // test user gets updated
      let updateUserReq = Request(method: .put, uri: "/user/\(userId)", headers: ["Content-Type": "application/json"], body: reqBody)
      let updateUserRes = try drop.testResponse(to: updateUserReq)
      
      updateUserRes.assertStatus(is: .ok)
      try updateUserRes.assertJSON("username", equals: newUn)
      
      /// MARK: CLEANUP
      try user.delete()
    }
    
    func testThatUserGetsDeleted() throws {
      
      /// MARK: PREPARING
      let user = Connection(username: "Jony", age: 23)
      try user.save()
      
      guard let userId = user.id?.int else {
        
        XCTFail("Error converting user id to int")
        return
      }
      
      /// MARK: TESTING
      let req = Request(method: .delete, uri: "/user/\(userId)", headers: ["Content-Type":"application/json"], body: Body())
      let res = try drop.testResponse(to: req)
      
      res.assertStatus(is: .ok)
      try res.assertJSON("type", equals: "success")
    }
}
