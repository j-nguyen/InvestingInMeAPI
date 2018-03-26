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
    let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
    let matches = detector.matches(in: input, options: [], range: NSMakeRange(0, input.count))
    
    guard let res = matches.first else {
      throw Abort(.badRequest, reason: "This is not a valid phone number!")
    }
    
    guard res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == input.count && input.count == 10 else {
      throw Abort(.badRequest, reason: "This isn't a valid phone number!")
    }
  }
}
