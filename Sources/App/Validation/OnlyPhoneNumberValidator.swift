//
//  OnlyPhoneNumberValidator.swift
//  App
//
//  Created by Johnny Nguyen on 2018-03-25.
//

import Foundation
import Validation

public struct OnlyPhoneNumberValidator: Validator {
  
  private let numeric = "0123456789"
  
    /// See Validator.inverseMessage
    public var inverseMessage: String {
      return "alphanumeric"
    }
    
    /// creates a new alphanumeric validator
    public init() {}
    
    /// See Validator.validate
    public func validate(_ input: String) throws {
        for char in input.lowercased() {
          guard numeric.contains(char) && input.count <= 10 else {
            throw Abort(.badRequest, reason: "Your phone number must be a maximum of 10 numbers only.")
          }
        }
      }
}

