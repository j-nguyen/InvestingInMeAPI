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
  
  //MARK: Show all Projects
  func index(_ request: Request) throws -> ResponseRepresentable {
    
    //Return all Projects
    return try Project.all().makeJSON()
  }
  
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
  
  //MARK: Update Project
  func update(_ request: Request) throws -> ResponseRepresentable {
    
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
    
    if request.headers["user_id"]?.int == project.user_id.int {
      
      //Update name, project_description, and description_needs if they have been passed through the url
      project.name = request.json?["name"]?.string ?? project.name
      project.project_description = request.json?["project_description"]?.string ?? project.project_description
      project.description_needs = request.json?["description_needs"]?.string ?? project.description_needs
      
      //Update category_id, and role_id if they have been requested to change
      if let category_id = request.json?["category_id"]?.int {
        project.category_id = Identifier(category_id)
      }
      
      if let role_id = request.json?["role_id"]?.int {
        project.role_id = Identifier(role_id)
      }
      
      //Save the project
      try project.save()
      
      //Return the project as JSON
      return try project.makeJSON()
    } else {
      throw Abort(.badRequest, reason: "You don't have the permissions to update this project.")
    }
  }
  
  //MARK: Delete Project
  func delete(_ request: Request) throws -> ResponseRepresentable {
    
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
    
    //Delete the project
    try project.delete()
    
    //Return a confirmation message that the project was deleted
    return try JSON(node: ["message", "\(project.name) has been deleted."])
  }
  
}

