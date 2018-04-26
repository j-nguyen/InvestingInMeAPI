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
  let notificationController = try! NotificationController(Droplet.getConfig())
  
  func testRoutes() throws {
    try fetchNotficiations()
  }
  
  func fetchNotficiations() throws {
    let req = Request.makeTest(method: .get, headers: ["user_id": "\(1)"])
    let res = try notificationController.index(req).makeResponse()
    
    res.assertStatus(is: .ok)
  }
}

extension NotificationControllerTests {
  static let allTests = [
    ("testRoutes", testRoutes)
  ]
}
