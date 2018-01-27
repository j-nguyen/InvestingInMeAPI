//
//  FeaturedProjectController.swift
//  App
//
//  Created by Liam Goodwin on 2018-01-26.
//

import Foundation
import Vapor
import HTTP

final class FeaturedProjectController {
  
  //MARK: Show all Featured Projects
  func index(_ request: Request) throws -> ResponseRepresentable {
    
    //Return all Featured Projects
    return try FeaturedProject.all().makeJSON()
  }
  
  //MARK: Create Feature Project
  func create(_ request: Request) throws -> ResponseRepresentable {
    
    //Pull the values from the request for each column
    guard let project_id = request.json?["project_id"]?.int, let duration = request.json?["duration"]?.int else {
      throw Abort.badRequest
    }
    
    //Instaniate the featured project using the variables we created
    let featuredProject = FeaturedProject(project_id: Identifier(project_id), duration: Int64(duration))
    
    //Save the new featured project
    try featuredProject.save()
    
    //Return the newly created featureProject
    return try featuredProject.makeJSON()
  }
  
  //MARK: Delete Features Project
  func delete(_ request: Request) throws -> ResponseRepresentable {
  
    //Declare the featured project id requested in the url
    guard let featured_project_id = request.parameters["id"]?.int
      else {
        throw Abort.badRequest
    }
    
    //Declare the featured project by searching the FeaturedProject model at the given feature_project_id
    guard let featured_project = try FeaturedProject.find(featured_project_id)
      else {
        throw Abort.notFound
    }
    
    //Declare the project by searching the Project model using the featured project, project_id
    guard let project = try Project.find(featured_project.project_id)
      else {
        throw Abort.notFound
    }
    
    //Delete the featured project
    try featured_project.delete()
    
    //Return a confirmation message that the featured project was deleted
    return try JSON(node: ["message", "\(project.name) is not longer being featured."])
  }
  
}