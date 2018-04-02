//
//  NotificationControllerTests.swift
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

class NotificationControllerTests: TestCase {
  let notificationController = NotificationController()
  
  func testRoutes() throws {
    guard let id = try createProject() else {
      XCTFail()
      return
    }
  }
  
}

extension NotificationControllerTests {
  static let allTests = [
    ("testRoutes", testRoutes)
  ]
}
