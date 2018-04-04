//
//  Date+.swift
//  InvestingInMeAPIPackageDescription
//
//  Created by Liam Goodwin on 2018-04-03.
//

import Foundation

extension Date {
  public var dateString: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E MMM d YYYY HH:mm:ss zzzz"
    return dateFormatter.string(from: self)
  }
} Foundation
