//
//  ProjectController.swift
//  App
//
//  Created by Liam Goodwin on 2018-01-25.
//

import Foundation
import Vapor
import HTTP

final class ProjectController {
  
  //MARK: Show Project
  func show(_ request: Request) throws -> ResponseRepresentable {
    
    //Declare the project_id requested in the url
    guard let project_id = request.parameters["id"]?.int
      else {
        throw Abort.badRequest
    }
    
    //Declare the project by searching the Project model at the given project_id
    guard let project = try Project.find(project_id)
      else {
        throw Abort.notFound
    }
    
    //Return project as JSON
    return try project.makeJSON()
  }
  
}

