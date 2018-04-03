//
//  FilterWordService.swift
//  Run
//
//  Created by Johnny Nguyen on 2018-04-02.
//

import Foundation
import Vapor

final class FilterWordService {
  
  init(forPath path: String) {
    readFile(path: path)
  }
  
  /// Reads a file, based on the path given
  private func readFile(path: String) throws -> String? {
    let file = FileManager.default
    
    if file.fileExists(atPath: path) {
      
    }
  }
}
