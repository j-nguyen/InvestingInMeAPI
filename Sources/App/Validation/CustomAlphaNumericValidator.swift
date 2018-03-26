//
//  CustomAlphaNumericValidator.swift
//  App
//
//  Created by Johnny Nguyen on 2018-03-26.
//

import Foundation
import Validation

/// A validator that can be used to check that a
/// given string contains only alphanumeric characters
public struct CustomAlphaNumericValidator: Validator {
  // MARK: Properties
  private let alphanumeric = "abcdefghijklmnopqrstuvwxyz0123456789 .!?@$%"
  
  public init() {}
  /**
   Validate whether or not an input string contains only
   alphanumeric characters. a...z0...9
   
   - parameter value: input value to validate
   
   - throws: an error if validation fails
   */
  public func validate(_ input: String) throws {
//    let passed = !input
//      .lowercased()
//      .contains { !alphanumeric.contains($0) }
//    
//    guard passed else {
//      throw Abort(.badRequest, reason: "You've entered something naughty! Please try again.")
//    }
  }
}

