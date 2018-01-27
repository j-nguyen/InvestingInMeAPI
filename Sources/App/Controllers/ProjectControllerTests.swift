//
//  ProjectControllerTests.swift
//  App
//
//  Created by Liam Goodwin on 2018-01-26.
//

import XCTest
import Testing
import HTTP
import Sockets
@testable import Vapor
@testable import App

class ProjectControllerTests: TestCase {
  
  let controller = ProjectController()
  
  func testPostRoutes() throws {
    guard let projectOne = try createNewProject(), let idOne = projectOne.id?.int else {
      XCTFail()
      return
    }
  }
  
  func createNewProject() throws -> Project? {
    let request = Request.maketest(method: .post)
    request.json = try JSON(node: ["user_id": 1, "name": "Test Name", "category_id": 1, "role_id": 1, "project_description": "Test project description", "description_needs": "Test description needs"])
    let response = try controller.create(req)
    
    XCTAssertNotNil(response)
    let newId: Int? = try response?.get("id")
    XCTAssertNotNil(newId)
    XCTAssertNotNil(json?["content"])
    return try Project.find(newId)
  }
  
}
