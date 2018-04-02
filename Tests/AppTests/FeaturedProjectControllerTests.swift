//
//  FeaturedProjectControllerTests.swift
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

class FeaturedProjectControllerTests: TestCase {
  
  let featuredProjectController = FeaturedProjectController()
  
  func testRoutes() throws {
    _ = try createFeaturedProject()
  }
  
  func createFeaturedProject() throws -> Int? {
    let project = try! Project(
      user_id: 1,
      name: "spokfd",
      category_id: Category.makeQuery().first()!.assertExists(),
      role_id: Role.makeQuery().first()!.assertExists(),
      project_description: "fg",
      description_needs: "sdf"
    )
    
    try project.save()
    
    let json = try JSON(node: ["project_id": project.id!.int, "duration": 86400])
    let req = Request.makeTest(method: .post, headers: ["user_id": "\(1)"])
    req.json = json
    
    let res = try featuredProjectController.create(req).makeResponse()

    res.assertStatus(is: .ok)
    
    XCTAssertNotNil(res.json?["id"]?.int)
    
    return res.json?["id"]?.int
  }
}

extension FeaturedProjectControllerTests {
  static let allTests = [
    (testRoutes, "testRoutes")
  ]
}
