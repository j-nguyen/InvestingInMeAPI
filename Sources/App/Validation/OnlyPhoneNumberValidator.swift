//
//  OnlyPhoneNumberValidator.swift
//  App
//
//  Created by Johnny Nguyen on 2018-03-25.
//

import Foundation
import Validation

public struct OnlyPhoneNumberValidator: Validator {
  
  public init() { }
  
  /**
   Validate whether or not this is a proper phone number, by testing the count length and location
   
   - parameter value: input value to validate
   
   - throws: an error if validation fails
   */
  public func validate(_ input: String) throws {
    guard input.range(of: "^\\d{3}-\\d{3}-\\d{4}$", options: [.regularExpression]) != nil else {
      throw Abort(.badRequest, reason: "Not a valid phone number!")
    }
    
  }
}
