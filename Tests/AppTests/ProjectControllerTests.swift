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
  let drop = try! Droplet.testable()
  let user = try! User.makeQuery().filter("email", "fakeuser@example.com").first()!
  
  func testCreateProject() throws {
    let project = try Project(
      user_id: user.assertExists(),
      name: "Project Test",
      category_id: Category.Group.game.category().assertExists(),
      role_id: Role.Group.developer.role().assertExists(),
      project_description: "Im a description",
      description_needs: "noo"
    )
    
    try project.save()
    
    XCTAssertNotNil(project)
  }
  
  func testUpdateProject() throws {
    let project: Project
    if try Project.makeQuery().filter("name", "Project Test").first() == nil {
      project = try Project(
        user_id: user.assertExists(),
        name: "Project Test",
        category_id: Category.Group.game.category().assertExists(),
        role_id: Role.Group.developer.role().assertExists(),
        project_description: "Im a description",
        description_needs: "noo"
      )
      
      try project.save()
    } else {
      project = try Project.makeQuery().filter("name", "Project Test").first()!
    }
    
    let desc = project.project_description
    project.project_description = "random"
    try project.save()
    
    XCTAssertNotEqual(desc, project.project_description)
  }
  
  func testDeleteProject() throws {
    let count = try Project.count()
    try FeaturedProject.makeQuery().delete()
    try Project.makeQuery().delete()
    XCTAssertNotEqual(count, try Project.count())
  }
}

extension ProjectControllerTests {
  static let allTests = [
    ("testCreateProject", testCreateProject),
    ("testUpdateProject", testUpdateProject),
    ("testDeleteProject", testDeleteProject)
  ]
}
