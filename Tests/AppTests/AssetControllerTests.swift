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
*/
class AssetControllerTests: TestCase {
  // our intitializers are at the setup here
  
  func testCreateRoute() throws {
    
  }
}

// MARK: Manifest
extension AssetControllerTests {
  /// This is a requirement for XCTest on Linux
  /// to function properly.
  /// See ./Tests/LinuxMain.swift for examples
  static let allTests = [
    ("testCreateRoute", testCreateRoute),
  ]
}
