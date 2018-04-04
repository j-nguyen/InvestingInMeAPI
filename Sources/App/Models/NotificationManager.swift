//
//  NotificationManager.swift
//  InvestingInMeAPIPackageDescription
//
//  Created by Liam Goodwin on 2018-04-03.
//

import Foundation
import Vapor
import FluentProvider

public final class NotificationManager: Model {
  public var uuid: String
  public var type: String
  public var type_id: Int
  
  
  public let storage: Storage = Storage()
  
  public init(uuid: String, type: String, type_id: Int) {
    self.uuid = uuid
    self.type = type
    self.type_id = type_id
  }
  
  public init(row: Row) {
    
  }
}
