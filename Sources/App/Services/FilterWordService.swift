//
//  FilterWordService.swift
//  Run
//
//  Created by Johnny Nguyen on 2018-04-02.
//

import Foundation
import Vapor

final class FilterWordService {
  
  var filteredWords: [String] = []
  
  /// Setup the initializer
  init(forPath path: String) throws {
    guard let string = try readFile(path: path) else {
      throw Abort(.internalServerError, reason: "Could not read file")
    }
    self.filteredWords = string
  }
  
  /// Reads a file, based on the path given
  private func readFile(path: String) throws -> [String]? {
    // Read the file contents
    do {
      // Separate them by new lines for the separated strings
      let string = try String(contentsOfFile: path)
      let separatedString = string.components(separatedBy: .newlines)
      return separatedString
      // Use the chance for separate strings to be added
    } catch {
      drop?.log.error("Could not retrieve files!")
      return nil
    }
  }
  
  /// Checks if the word in there contains a string
  public func isBadWord(forContent content: String) -> Bool {
    return filteredWords.contains(where: { $0.range(of: content, options: .caseInsensitive) != nil})
  }
}
