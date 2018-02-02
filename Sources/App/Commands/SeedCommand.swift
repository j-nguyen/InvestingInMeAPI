import Vapor
import HTTP
import Console
import Random

/**
 SeedCommand is a way to prepopulate our data, so that we know what it'll look like on the front-end of our application.
 This way, we can be sure that we've extensively tested our app. To run this command you would do `vapor run seed`
*/
final class SeedCommand: Command {
  // MARK: Properties
  let id: String = "seed"
  let help: [String] = ["Helps populate data so that we know what our application is going to look like"]
  let console: ConsoleProtocol
  let environment: Environment
  let user: Config?
  let project: Config?
  let asset: Config?
  
  init(console: ConsoleProtocol, environment: Environment, seeds: Config?) {
    self.console = console
    self.environment = environment
    self.user = seeds?["user"]
    self.project = seeds?["project"]
    self.asset = seeds?["asset"]
  }
  
  func createUsers() throws {
    if let user = user {
      let tempVariable:[String] = try user.get("phone_number")
      let roles = try Role.all()
      for i in 1...10 {
        let email: String = try String(i) + user.get("email")
        let role = roles.random
        if let role = role {
          let userObject = try User.init(google_id: URandom().makeInt(), email: email, name: user.get("name"), picture: user.get("picture"), email_verification: user.get("email_verification"), description: user.get("description"), role_id: role.assertExists(), experience_and_credentials: user.get("experience_and_credentials"))
          userObject.phone_number = tempVariable.random ?? ""
          try userObject.save()
        }
      }
    }
  }
  
  func createProjects() throws {
    if let project = project {
      let users = try User.all()
      let categories = try Category.all()
      let roles = try Role.all()
      for i in 1...50 {
        let user = users.random
        let category = categories.random
        let role = roles.random
        if let user = user, let category = category, let role = role {
          let name: String = try project.get("name") + String(i)
          let projectObject = try Project.init(user_id: user.assertExists(), name: name, category_id: category.assertExists(), role_id: role.assertExists(), project_description: project.get("project_description"), description_needs: project.get("description_needs"))
          try projectObject.save()
        }
      }
    }
  }
  
  func createAssets() throws {
    if let asset = asset {
      let projects = try Project.all()
      for _ in 1...50 {
        let project = projects.random
        if let project = project {
          let assetObject = try Asset.init(project_id: project.assertExists(), file_type: asset.get("file_type"), url: asset.get("url"), file_name: asset.get("file_name"), file_size: asset.get("file_size"), project_icon: asset.get("project_icon"), public_id: "123")
          try assetObject.save()
        }
      }
    }
  }
  
  func createConnections() throws {
    let users = try User.all()
    let accepted_types = [true, false]
    for _ in 1...10 {
      guard let invitee_user = users.random else {return}
      guard var inviter_user = users.random else {return}
      repeat { inviter_user = users.random! } while inviter_user.id! == invitee_user.id!
      let accepted = accepted_types.random
      if let accepted = accepted {
        let connectionObject = try Connection.init(inviter_id: inviter_user.assertExists(), invitee_id: invitee_user.assertExists(), accepted: accepted, message: "Hey, i'd like to connect!")
        try? connectionObject.save()
      }
    }
  }
  
  func createFeaturedProjects() throws {
    for _ in 1...3 {
      let projects = try Project.all()
      let project = projects.random
      if let project = project {
        let featuredProjectObject = try FeaturedProject.init(project_id: project.assertExists(), duration: 86400)
        try? featuredProjectObject.save()
      }
    }
  }
  
  func run(arguments: [String]) throws {
    
    // Changed it up so that now it'll only delete if the specified values do not exist
    if try Role.count() == 0 {
      //Declare the roles we will allow
      let roles = Role.Group.allValues

      //Iterate through the list of roles
      for current_role in roles {

        //Create a new role based on the current_role
        let role = Role(role: current_role)

        //Save the role
        try role.save()
      }
    }
    
    // Check it now for Categories
    if try Category.count() == 0 {
      //Declare the categories we will allow
      let categories = Category.Group.allValues

      //Iterate through the list of categories
      for current_category in categories {

        //Create a new category based on the current_category
        let category = Category(type: current_category)

        //Save the category
        try category.save()
      }
    }
    
    if environment == .development {
      try createUsers()
      try createProjects()
      try createAssets()
      try createConnections()
      try createFeaturedProjects()
    }
  }
}

// MARK: ConfigInitializable
extension SeedCommand: ConfigInitializable {
  convenience init(config: Config) throws {
    let console = try config.resolveConsole()
    let seeds = config["seeds"]
    self.init(console: console, environment: config.environment, seeds: seeds)
  }
}
