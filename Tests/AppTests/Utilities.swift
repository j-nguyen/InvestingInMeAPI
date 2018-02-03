import Foundation
@testable import App
@testable import Vapor
import XCTest
import Testing
import FluentProvider

extension Droplet {
  static func testable() throws -> Droplet {
    let config = try Config(arguments: ["vapor", "--env=test"])
    try config.setup()
    let drop = try Droplet(config)
    try drop.setup()
    
    // Changed it up so that now it'll only delete if the specified values do not exist
    if try Role.count() == 0 {
      //Declare the roles we will allow
      let roles = Role.Group.allValues
      //Iterate through the list of roles
      for current_role in roles {
        //Create a new role based on the current_role
        let role = Role(role: current_role)
        //Save the role
        try role.save()
      }
    }
    
    // Check it now for Categories
    if try Category.count() == 0 {
      //Declare the categories we will allow
      let categories = Category.Group.allValues
      
      //Iterate through the list of categories
      for current_category in categories {
        //Create a new category based on the current_category
        let category = Category(type: current_category)
        //Save the category
        try category.save()
      }
    }
    return drop
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
  }
}
