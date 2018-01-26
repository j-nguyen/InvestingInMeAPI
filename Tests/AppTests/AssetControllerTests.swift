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
  // our intitializers are at the setup here
  
  let controller = AssetController()
  
  /**
    We'll test creating a route aka creating an asset
  */
  func testCreateRoute() throws {
    
  }
  
  /**
   Test based on the delete route
  */
  func testDeleteRoute() throws {
    
  }
}

// MARK: Manifest
extension AssetControllerTests {
  /// This is a requirement for XCTest on Linux
  /// to function properly.
  /// See ./Tests/LinuxMain.swift for examples
  static let allTests = [
    ("testCreateRoute", testCreateRoute),
    ("testDeleteRoute", testDeleteRoute)
  ]
}
