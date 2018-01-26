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
  func index(_ reuqest: Request) throws -> ResponseRepresentable {
    
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
  
  func create(_ request: Request) throws -> ResponseRepresentable {
    
    //Pull the values from the request for each column
    guard let user_id = request.json?["user_id"]?.int, let name = request.json?["name"]?.string, let category_id = request.json?["category_id"]?.int, let role_id = request.json?["role_id"]?.int, let project_description = request.json?["project_description"]?.string, let description_needs = request.json?["description_needs"]?.string else {
      throw Abort.badRequest
    }
    
    //Instaniate the project using the variables we created
    let project = Project(user_id: Identifier(user_id), name: name, category_id: Identifier(category_id), role_id: Identifier(role_id), project_description: project_description, description_needs: description_needs)
    
    //Save the new project
    try project.save()
    
    //Return the newly created project
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
  }
  
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
    
    //Return project as JSON
    try project.delete()
    
    //Return a confirmation message that the project was deleted
    return try JSON(node: ["message", "\(project.name) has been deleted."])
  }
  
}

