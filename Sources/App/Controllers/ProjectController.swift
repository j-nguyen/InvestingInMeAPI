//
//  ProjectController.swift
//  App
//
//  Created by Liam Goodwin on 2018-01-25.
//

import Foundation
import Vapor
import HTTP
import Validation

final class ProjectController {
  
  private let config: Config
  
  init(_ config: Config) {
    self.config = config
  }
  
  //MARK: Show all Projects
  func index(_ request: Request) throws -> ResponseRepresentable {
    let projects = try Project.makeQuery()
    
    if let categories: [String] = try request.query?.get("category") {
      try projects.or { orGroup in
        for category in categories {
          guard let categoryGroup = Category.Group(rawValue: category) else {
            throw Abort(.badRequest, reason: "There is no category named this!")
          }
          try orGroup.filter("category_id", categoryGroup.category().assertExists())
        }
      }
    }
    
    if let roles: [String] = try request.query?.get("role") {
      try projects.or { orGroup in
        for role in roles {
          guard let roleGroup = Role.Group(rawValue: role) else {
            throw Abort(.badRequest, reason: "There is no role named this!")
          }
          try orGroup.filter("role_id", roleGroup.role().assertExists())
        }
      }
      
    }
    if let search = request.query?["search"]?.string {
      // attempt to search through by project name
       try projects.or { try $0.filter("name", .custom("~*"), search) }
    }
    
    
    //Return all Projects
    return try projects
      .sort("created_at", .descending)
      .filter("user_id", .notEquals, request.headers["user_id"]?.int)
      .all()
      .makeJSON()
  }
  
  //MARK: Show Project
  func show(_ request: Request) throws -> ResponseRepresentable {
    
    //Declare the project_id requested in the url
    guard let project_id = request.parameters["id"]?.int else {
      throw Abort.badRequest
    }
    
    //Declare the project by searching the Project model at the given project_id
    guard let project = try Project.find(project_id) else {
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
    
    //Check if the user requesting the update is equal to the project user_id
    guard request.headers["user_id"]?.int == project.user_id.int else {
      throw Abort(.forbidden, reason: "You don't have permissions to update this project.")
    }
    
    //Update name, project_description, and description_needs if they have been passed through the url

    // Check for word filter
    let filterWordService = try FilterWordService(forPath: "\(config.workDir)badwords.txt")
    
    // Add validations for these specific naming schemes
    if let name = request.json?["name"]?.string {
      try CustomASCIIValidator().validate(name)
      guard !filterWordService.isBadWord(forContent: name) else {
        throw Abort(.badRequest, reason: "Your name contains profanity!")
      }
      project.name = name
    }
    
    // Check for the project description
    if let project_description = request.json?["project_description"]?.string {
      try CustomASCIIValidator().validate(project_description)
      guard !filterWordService.isBadWord(forContent: project_description) else {
        throw Abort(.badRequest, reason: "Your project description contains profanity!")
      }
      project.project_description = project_description
    }
    
    // Now check for description needs
    if let description_needs = request.json?["description_needs"]?.string {
      try CustomASCIIValidator().validate(description_needs)
      guard !filterWordService.isBadWord(forContent: description_needs) else {
        throw Abort(.badRequest, reason: "Your project needs contains profanity!")
      }
      project.description_needs = description_needs
    }
    
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
    
    //Check if the user requesting the update is equal to the project user_id
    if request.headers["user_id"]?.int == project.user_id.int {
      
      try project.featured.delete()
      
      //Declare the assets associated with the Project by searching the project_id
      let assets = try project.assets.all()
      
      //Go through each asset and attempt to delete it
      for asset in assets {
        try asset.delete()
      }
      
      //Delete the project
      try project.delete()
      
      //Return a confirmation message that the project was deleted
      return try JSON(node: ["message", "\(project.name) has been deleted."])
    } else {
      throw Abort(.forbidden, reason: "You don't have the permissions to delete this project.")
    }
  }
  
  // MARK: Gets all categories
  /// Gets all the categories
  func categories(_ req: Request) throws -> ResponseRepresentable {
    return try Category
      .all()
      .makeJSON()
  }
}

