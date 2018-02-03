//
//  AssetControllerTests.swift
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

class AssetControllerTests: TestCase {
  
  let drop = try! Droplet.testable()
  
  var user: User?
  var project: Project?
  
  override func setUp() {
    super.setUp()
    Testing.onFail = XCTFail
    // create some initial setup for project and user
    user = try! User(google_id: URandom().makeInt(), email: "fakeuser@example.com", name: "Fake User", picture: "", email_verification: true)
    try! user!.save()
    // attempt to create the project next
    project = try! Project(
      user_id: user!.assertExists(),
      name: "Project",
      category_id: Category.Group.mobileApp.category().assertExists(),
      role_id: Role.Group.developer.role().assertExists(),
      project_description: "sdfsdf",
      description_needs: "sdfspdf"
    )
    try! project!.save()
  }

  func testCreateAsset() throws {
    // we don't want to use the cloudinary service, so we'll use the manual test in here
    let asset = try Asset(
      project_id: project!.assertExists(),
      file_type: "Image",
      url: "http://via.placeholder.com/1x1",
      file_name: "placeholder",
      file_size: 12351,
      project_icon: false,
      public_id: "dsopfk"
    )
    
    try asset.save()
    
    // attempt
    XCTAssertNotNil(asset)
  }
  
  func testDeleteAssets() throws {
    // attempt to delete all assets
    try Asset.makeQuery().delete()
    
    XCTAssertEqual(0, try Asset.count())
  }
}
