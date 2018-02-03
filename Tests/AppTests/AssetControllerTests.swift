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
@testable import Vapor
@testable import App

class AssetControllerTests: TestCase {
  
  let drop = try! Droplet.testable()
  
  override func setUp() {
    super.setUp()
    Testing.onFail = XCTFail
  }

  func testInfo() throws {
    try drop
      .testResponse(to: .get, at: "info")
      .assertStatus(is: .ok)
      .assertBody(contains: "0.0.0.0")
  }
}
