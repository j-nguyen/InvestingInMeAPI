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
  let drop = try! Droplet.testable()
  let user = try! User.makeQuery().filter("email", "fakeuser@example.com").first()!
  
  func testCreateFeaturedProject() throws {
    let project = try Project(
      user_id: user.assertExists(),
      name: "Featured Project Test",
      category_id: Category.Group.mobileApp.category().assertExists(),
      role_id: Role.Group.developer.role().assertExists(),
      project_description: "SDFgdfgd",
      description_needs: "sdofisjodf"
    )
    
    try project.save()
    
    XCTAssertNotNil(project)
    
    let featured = try FeaturedProject(project_id: project.assertExists(), duration: 234234235)
    try featured.save()
    
    XCTAssertNotNil(featured)
  }
  
  func testUpdateFeaturedProject() throws {
    // make sure it's there
    let featured: FeaturedProject
    if try FeaturedProject.makeQuery().first() == nil {
      // recreate the project and test the description
      let project = try Project(
        user_id: user.assertExists(),
        name: "Featured Project Test",
        category_id: Category.Group.mobileApp.category().assertExists(),
        role_id: Role.Group.developer.role().assertExists(),
        project_description: "SDFgdfgd",
        description_needs: "sdofisjodf"
      )
      try project.save()
      // and then attempt for the featured project here
      featured = try FeaturedProject(project_id: project.assertExists(), duration: 123423)
      try featured.save()
    } else {
      featured = try FeaturedProject.makeQuery().first()!
    }
    
    XCTAssertNotNil(featured)
    
    // change the duration
    let duration = featured.duration
    featured.duration = 212142
    try featured.save()
    
    XCTAssertNotEqual(duration, featured.duration)
  }
  
  func testDeleteFeaturedProject() throws {
    try FeaturedProject.makeQuery().delete()
    // then attempt to delete it after
    XCTAssertEqual(0, try FeaturedProject.count())
  }
}

extension FeaturedProjectControllerTests {
  static let allTests = [
    ("testCreatedFeaturedProject", testCreateFeaturedProject),
    ("testUpdateFeaturedProject", testUpdateFeaturedProject),
    ("testDeleteFeaturedProject", testDeleteFeaturedProject)
  ]
}
