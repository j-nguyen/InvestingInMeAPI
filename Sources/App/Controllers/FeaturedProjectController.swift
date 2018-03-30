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
    
    let projects = try FeaturedProject.makeQuery().sort("startDate", .descending).limit(6).all()
    var notExpired: [FeaturedProject] = []
    
    if projects.count <= 1 {
      let startDate = TimeInterval(projects[0].startDate.timeIntervalSince1970 + TimeInterval(projects[0].duration))
      let endDate = Date().timeIntervalSince1970
      
      if startDate > endDate {
        notExpired.append(projects[0])
      } else {
        try projects[0].delete()
      }
      
    } else {
    
      let half = projects.count / 2
      var counterExpire = half
      
      for i in 0..<half {
        let startDate = TimeInterval(projects[i].startDate.timeIntervalSince1970 + TimeInterval(projects[i].duration))
        let endDate = Date().timeIntervalSince1970
        if startDate > endDate {
          notExpired.append(projects[i])
        } else {
          counterExpire += 1
          try projects[i].delete()
        }
      }
      
      for i in half..<counterExpire {
          projects[i].startDate = Date()
          try projects[i].save()
          notExpired.append(projects[i])
      }
    }
    
    //Return all Featured Projects
    return try notExpired.makeJSON()
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
    
    guard request.headers["user_id"]?.int == project.user_id.int else {
      throw Abort(.forbidden, reason:  "You're not the owner of this project")
    }
    
    //Delete the featured project
    try featured_project.delete()
    
    //Return a confirmation message that the featured project was deleted
    return try JSON(node: ["message", "\(project.name) is not longer being featured."])
  }
  
}
