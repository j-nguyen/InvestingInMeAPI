import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

/// This file shows an example of testing 
/// routes through the Droplet.

class RouteTests: TestCase {
  let drop = try! Droplet.testable()
  
  /// Testing for asset
  func testCreateAsset() throws {
    // create the json response
    let json = try JSON(node: [
      "file": "http://via.placeholder.com/1x1",
      "type": "image",
      "project_icon": false
    ]).makeBody()
    
    let headers: [HeaderKey: String] = [.contentType: "application/json"]
    
    try drop
      .testResponse(to: .post, at: "api/v1/assets", headers: headers, body: json)
      .assertStatus(is: .ok)
      .json?["id"]?.int
  }
  
  /// Attempts to delete it after
  func testDropAssets() throws {
    // using that asset id i can try to drop
    let assets = try Asset.all()
    
    try assets.forEach { asset in 
      try drop
        .testResponse(to: .delete, at: "api/v1/assets/\(asset.assertExists().int!)")
        .assertStatus(is: .ok)
    }
  }
  
  
  func testHello() throws {
    try drop
      .testResponse(to: .get, at: "hello")
      .assertStatus(is: .ok)
      .assertJSON("hello", equals: "world")
  }
  
  func testInfo() throws {
    try drop
      .testResponse(to: .get, at: "info")
      .assertStatus(is: .ok)
      .assertBody(contains: "0.0.0.0")
  }
}

// MARK: Manifest

extension RouteTests {
  /// This is a requirement for XCTest on Linux
  /// to function properly.
  /// See ./Tests/LinuxMain.swift for examples
  static let allTests = [
    ("testHello", testHello),
    ("testInfo", testInfo),
    ("testCreateAsset", testCreateAsset)
  ]
}
