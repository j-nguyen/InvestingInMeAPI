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
    // create some initial setup
    
  }

  func testCreateAsset() throws {
    // we don't want to use the cloudinary service, so we'll use the manual test in here
    let asset = Asset(project_id: <#T##Identifier#>, file_type: <#T##String#>, url: <#T##String#>, file_name: <#T##String#>, file_size: <#T##Int64#>, project_icon: <#T##Bool#>, public_id: <#T##String#>)
    
  }
}
