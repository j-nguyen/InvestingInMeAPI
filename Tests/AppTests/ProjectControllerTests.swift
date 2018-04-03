//
//  ProjectControllerTests.swift
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

class ProjectControllerTests: TestCase {
  let userController = UserController()
  let projectController = ProjectController()
  
  func testRoutes() throws {
    guard let id = try createProject() else {
      XCTFail()
      return
    }
    
    try fetchUserProjects(id: id)
    try fetchProjects()
    try fetchProject(id: id)
    try editProject(id: id)
    try deleteProject(id: id)
  }
  
  func fetchUserProjects(id: Int) throws {
    let req = Request.makeTest(method: .get)
    req.parameters["id"] = Parameters(id)
    let res = try userController.userProjects(req).makeResponse()
    
    res.assertStatus(is: .ok)
  }
  
  func fetchProjects() throws {
    let req = Request.makeTest(method: .get, headers: ["user_id": "\(1)"])
    let res = try projectController.index(req).makeResponse()
    
    res.assertStatus(is: .ok)
  }
  
  func createProject() throws -> Int? {
    let req = Request.makeTest(method: .post, headers: ["user_id": "\(1)"])
    req.json = try JSON(node: [
      "user_id": 1,
      "name": "Test",
      "category_id": try Category.makeQuery().first()!.id!.int!,
      "role_id": try Role.makeQuery().first()!.id!.int!,
      "project_description": "this is a desc",
      "description_needs": "SDFSDPFS"
    ])
    let res = try userController.createProject(req).makeResponse()
    
    res.assertStatus(is: .ok)
    XCTAssertNotNil(res.json?["id"]?.int)
    
    return res.json?["id"]?.int
  }
  
  func fetchProject(id: Int) throws {
    let req = Request.makeTest(method: .get, headers: ["user_id": "\(1)"])
    req.parameters["id"] = Parameters(id)
    let res = try projectController.show(req).makeResponse()
    
    res.assertStatus(is: .ok)
  }
  
  func editProject(id: Int) throws {
    let req = Request.makeTest(method: .patch, headers: ["user_id": "\(1)"])
    req.parameters["id"] = Parameters(id)
    req.json = try JSON(node: ["name": "ABC"])
    let res = try projectController.update(req).makeResponse()
    
    XCTAssertNotNil(res.json?["name"]?.string)
    XCTAssertNotEqual(res.json?["name"]?.string, "Test")
  }
  
  func deleteProject(id: Int) throws {
    let req = Request.makeTest(method: .delete, headers: ["user_id": "\(1)"])
    req.parameters["id"] = Parameters(id)
    let res = try projectController.delete(req).makeResponse()
    
    res.assertStatus(is: .ok)
  }
}

extension ProjectControllerTests {
  static let allTests = [
    ("testRoutes", testRoutes)
  ]
}
