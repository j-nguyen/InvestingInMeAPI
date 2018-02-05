//
//  DropCommand.swift
//  App
//
//  Created by Johnny Nguyen on 2018-01-27.
//

import Foundation
import Vapor
import Console

/**
 Helps us drop all the tables on Postgres, and re-creates the database for us
*/
final class DropCommand: Command {
  let id: String = "drop"
  let help: [String] = ["Drops all of our tables"]
  let console: ConsoleProtocol
  
  init(console: ConsoleProtocol) {
    self.console = console
  }
  
  func run(arguments: [String]) throws {
    try drop?.database?.raw("DROP SCHEMA public CASCADE;")
    try drop?.database?.raw("CREATE SCHEMA public;")
//    try drop?.database?.raw("GRANT ALL ON SCHEMA public TO postgres;")
    try drop?.database?.raw("GRANT ALL ON SCHEMA public TO public;")
  }
}

extension DropCommand: ConfigInitializable {
  convenience init(config: Config) throws {
    let console = try config.resolveConsole()
    self.init(console: console)
  }
}
