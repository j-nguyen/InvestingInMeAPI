//
//  AssetControllerTests.swift
//  AppTests
//
//  Created by Johnny Nguyen on 2018-01-25.
//

import XCTest
import Testing
import HTTP
import Sockets
@testable import Vapor
@testable import App

/**
 AssetController setup, this is done without a "live" server, since it's much more effective.
 Unfournately, AssetController requires me to actually use a live server, so I can't do this
*/
class AssetControllerTests: TestCase {
  // setup a fake drop
  let server = try! Droplet.testable()
  
  /// Setup the tests before beginning
  /// We'll delete everything from assets before beginning too
  override func setUp() {
    super.setUp()
    Testing.onFail = XCTFail
    // also set up the project too
    try! Asset.makeQuery().delete()
  }
  
  /// Testing for asset
  func testCreateAsset() throws {
    // create the json response
    let json = try JSON(node: [
      "file": "http://via.placeholder.com/1x1",
      "type": "image",
      "project_icon": false
      ]).makeBody()
    
    let headers: [HeaderKey: String] = [.contentType: "application/json"]
    
    try server
      .testResponse(to: .post, at: "api/v1/assets", headers: headers, body: json)
      .assertStatus(is: .ok)
      .json?["id"]?.int
  }
  
  /// Attempts to delete it after
  func testDropAssets() throws {
    // using that asset id i can try to drop
    let assets = try Asset.all()
    
    try assets.forEach { asset in
      try server
        .testResponse(to: .delete, at: "api/v1/assets/\(asset.assertExists().int!)")
        .assertStatus(is: .ok)
    }
  }
}

// MARK: Manifest
extension AssetControllerTests {
  /// This is a requirement for XCTest on Linux
  /// to function properly.
  /// See ./Tests/LinuxMain.swift for examples
  static let allTests = [
    ("testCreateAsset", testCreateAsset),
    ("testDropAsset", testDropAssets)
  ]
}
