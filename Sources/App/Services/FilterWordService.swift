//
//  FilterWordService.swift
//  Run
//
//  Created by Johnny Nguyen on 2018-04-02.
//

import Foundation
import Vapor

final class FilterWordService {
  // MARK: Properties
  private var filteredWords: [String] = []
  
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
      let url = URL(fileURLWithPath: path)
      let string = try String(contentsOf: url)
      let separatedString = string.components(separatedBy: .newlines)
      return separatedString
      // Use the chance for separate strings to be added
    } catch let e {
      drop?.log.error("ERROR: \(e)")
      return nil
    }
  }
  
  /// Checks if the word in there contains a string
  public func isBadWord(forContent content: String) -> Bool {
    //: TODO- I Believe there's a faster way to do this, but this is good enough
    return filteredWords.contains(where: { content.contains($0) })
  }
}
