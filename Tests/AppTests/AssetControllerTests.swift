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
  let assetController = try! AssetController(Droplet.getConfig())
  
  func testRoutes() throws {
    guard let id = try createAsset() else {
      XCTFail()
      return
    }
    
    try deleteAsset(id: id)
  }

  func createAsset() throws -> Int? {
    let project = try Project(
      user_id: 1,
      name: "OPFKSD",
      category_id: try Category.makeQuery().first()!.assertExists(),
      role_id: try Role.makeQuery().first()!.assertExists(),
      project_description: "sdfksm",
      description_needs: "sldkmf"
    )
    try project.save()
    
    // we don't want to use the cloudinary service, so we'll use the manual test in here
    let asset = try Asset(
      project_id: project.assertExists(),
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
    
    return asset.id?.int
  }
  
  func deleteAsset(id: Int) throws {
    let req = Request.makeTest(method: .delete, headers: ["user_id": "\(1)"])
    req.parameters["id"] = Parameters(id)
    
    let res = try assetController.delete(req).makeResponse()
    
    res.assertStatus(is: .ok)
  }
}

// MARK: XCTest - Linux
extension AssetControllerTests {
  static let allTests = [
    ("testRoutes", testRoutes)
  ]
}
