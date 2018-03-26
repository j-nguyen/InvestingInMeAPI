//
//  OnlyPhoneNumberValidator.swift
//  App
//
//  Created by Johnny Nguyen on 2018-03-25.
//

import Foundation
import Validation

public struct OnlyPhoneNumberValidator: Validator {
  
  private let allowedCharacters = "0123456789"
  
  public init() { }
  
  /**
   Validate whether or not this is a proper phone number, by testing the count length and location
   
   - parameter value: input value to validate
   
   - throws: an error if validation fails
   */
  public func validate(_ input: String) throws {
    let passed = !input
      .lowercased()
      .contains { !allowedCharacters.contains($0) }
    
    try Count.max(10).validate(input)
    
    guard passed else {
      throw Abort(.badRequest, reason: "You've entered something naughty! Please try again.")
    }
  }
}
