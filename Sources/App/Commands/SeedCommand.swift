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
  let assets: [Config]?
  
  init(console: ConsoleProtocol, environment: Environment, seeds: Config?) {
    self.console = console
    self.environment = environment
    self.user = seeds?["user"]
    self.project = seeds?["project"]
    self.assets = seeds?["assets"]?.array
  }
  
  func createUser() throws {
    if let user = user {
      let userObj = try User(
        google_id: user.get("google_id"),
        email: user.get("email"),
        name: user.get("name"),
        picture: user.get("picture"),
        email_verification: user.get("email_verification")
      )
      userObj.description = try user.get("description")
      userObj.experience_and_credentials = try user.get("experience_and_credentials")
      userObj.phone_number = try user.get("phone_number")
      try userObj.save()
    }
  }
  
  func createProjects() throws {
    if let project = project, let user = try User.makeQuery().first() {
      let category = try Category.Group.mobileApp.category()
      let role = try Role.Group.developer.role()
      for i in 1...25 {
        let name: String = try project.get("name") + String(i)
        let projectObject = try Project(
          user_id: user.assertExists(),
          name: name,
          category_id: category.assertExists(),
          role_id: role.assertExists(),
          project_description: project.get("project_description"),
          description_needs: project.get("description_needs")
        )
        try projectObject.save()
        console.print("~~~~ Saved \(projectObject.name) ~~~~~")
      }
    }
  }
  
  func createAssets() throws {
    if let assets = assets {
      let projects = try Project.all()
      for project in projects {
        var isSet = true
        for _ in 1...4 {
          // Set the beginning to have the icon true and the rest not
          let assetObj = try Asset(
            project_id: project.assertExists(),
            file_type: assets[0].get("file_type"),
            url: assets[0].get("url"),
            file_name: assets[0].get("file_name"),
            file_size: assets[0].get("file_size"),
            project_icon: isSet,
            public_id: "1234"
          )
          try assetObj.save()
          console.print("~~~~ Saved Picture ~~~~~")
          // this is only set once
          if isSet {
            isSet = false
          }
        }
        // Create the video here
        let videoObj = try Asset(
          project_id: project.assertExists(),
          file_type: assets[1].get("file_type"),
          url: assets[1].get("url"),
          file_name: assets[1].get("file_name"),
          file_size: assets[1].get("file_size"),
          project_icon: isSet,
          public_id: "1234"
        )
        try videoObj.save()
        console.print("~~~~ Saved Video ~~~~~")
      }
    }
  }
  
  func createFeaturedProjects() throws {
    for _ in 1...3 {
      let projects = try Project.all()
      let project = projects.random
      if let project = project {
        let featuredProjectObject = try FeaturedProject(project_id: project.assertExists(), duration: 86400)
        try? featuredProjectObject.save()
        console.print("~~~~ Saved Featured Project ~~~~")
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
      try createUser()
      try createProjects()
      try createAssets()
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
