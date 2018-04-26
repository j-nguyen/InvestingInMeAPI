import Foundation
@testable import App
@testable import Vapor
import XCTest
import Testing
import FluentProvider
import Random

extension Droplet {
  static func testable() throws -> Droplet {
    let config = try Config(arguments: ["vapor", "--env=test"])
    try config.setup()
    let drop = try Droplet(config)
    try drop.setup()

    return drop
  }
  
  static func getConfig() throws -> Config {
    let config = try Config(arguments: ["vapor", "--env=test"])
    try config.setup()
    return config
  }
  
  func serveInBackground() throws {
    background {
      try! self.run()
    }
    console.wait(seconds: 0.5)
  }
}

class TestCase: XCTestCase {
  override func setUp() {
    Node.fuzzy = [Row.self, JSON.self, Node.self]
    Testing.onFail = XCTFail
    
    _ = try! Droplet.testable()
    
    // We can just set up the user here
    try! Asset.makeQuery().delete()
    try! FeaturedProject.makeQuery().delete()
    try! Project.makeQuery().delete()
    try! Connection.makeQuery().delete()
    try! Notification.makeQuery().delete()
  }
}
