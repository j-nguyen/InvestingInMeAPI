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
    // Separate them by new lines for the separated strings
    guard let string = FileManager.default.contents(atPath: path)?.makeString() else {
      return nil
    }
    let separatedString = string.components(separatedBy: .newlines)
    return separatedString
  }
  
  /// Checks if the word in there contains a string
  public func isBadWord(forContent content: String) -> Bool {
    //: TODO- I Believe there's a faster way to do this, but this is good enough
    var delimiterSet = CharacterSet()
    delimiterSet.formUnion(.punctuationCharacters)
    delimiterSet.formUnion(.whitespacesAndNewlines)
    
    let separatedStrings = content.components(separatedBy: delimiterSet)
    
    for word in filteredWords {
      if let _ = separatedStrings.index(where: { $0.lowercased() == word.lowercased() }) {
        return true
      }
    }
    
    return false
  }
}
