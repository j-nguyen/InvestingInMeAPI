//
//  CustomASCIIValidator.swift
//  App
//
//  Created by Johnny Nguyen on 2018-04-09.
//

import Foundation
import Validation

public struct CustomASCIIValidator: Validator {
  /// creates a new ASCII validator
  public init() {}
  
  /// See Validator.validate
  public func validate(_ data: String) throws {
    guard data.range(of: "^[\\x09-\\x0d -~]+$", options: [.regularExpression, .caseInsensitive]) != nil else {
      throw Abort(.badRequest, reason: "is not ASCII")
    }
  }
}
