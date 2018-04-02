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
    // Create Dev Acc
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
      userObj.role_id = try Role.Group.developer.role().assertExists()
      
      try userObj.save()
      
      // Setup the user projects now
      if let project = project {
        for i in 1...10 {
          let categories = Category.Group.allValues
          for category in categories {
            let role = Role.Group.allValues
            guard let categoryGroup = Category.Group(rawValue: category) else { return }
            guard let roleGroup = Role.Group(rawValue: role.random ?? Role.Group.developer.rawValue) else { return }
            let projectObj = try Project(
              user_id: userObj.assertExists(),
              name: "User \(project.get("name") as String) - \(i)",
              category_id: categoryGroup.category().assertExists(),
              role_id: roleGroup.role().assertExists(),
              project_description: project.get("project_description"),
              description_needs: project.get("description_needs")
            )
            try projectObj.save()
            console.print("~~~~~~ User Saved \(projectObj.name) ~~~~~~~")
          }
        }
      }
    }
  }
  
  func createProjects() throws {
    // Random Accounts
    for i in 1...15 {
      let userObj = try User(
        google_id: "\(URandom.makeInt())",
        email: "\(i)email@example.com",
        name: "User \(i)",
        picture: "https://lh4.googleusercontent.com/-odK3p3pgzIc/AAAAAAAAAAI/AAAAAAAAAAA/ACSILjUEWrHe0j_9GxV1yT2oVaObU557-Q/s96-c/photo.jpg",
        email_verification: true
      )
      userObj.role_id = try Role.Group.marketer.role().assertExists()
      try userObj.save()
      
      for i in 1...3 {
        if let project = project {
          
          let category = try Category.Group.mobileApp.category()
          let role = try Role.Group.developer.role()
          let name: String = try project.get("name") + String(i)
          let projectObject = try Project(
            user_id: userObj.assertExists(),
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
  }
  
  func createAssets() throws {
    if let assets = assets {
      let projects = try Project.all()
      for project in projects {
        let assetProfile = try Asset(
          project_id: project.assertExists(),
          file_type: assets[0].get("file_type"),
          url: project.name.generatePlaceholder(),
          file_name: "file-\(project.assertExists().int!)",
          file_size: assets[0].get("file_size"),
          project_icon: true
        )
        try assetProfile.save()
        console.print("~~~~ Saved App Profile Icon ~~~~")
        for _ in 1...3 {
          // Set the beginning to have the icon true and the rest not
          let assetObj = try Asset(
            project_id: project.assertExists(),
            file_type: assets[0].get("file_type"),
            url: assets[0].get("url"),
            file_name: assets[0].get("file_name"),
            file_size: assets[0].get("file_size"),
            project_icon: false,
            public_id: "1234"
          )
          try assetObj.save()
          console.print("~~~~ Saved Picture ~~~~~")
        }
      }
    }
  }
  
  func createFeaturedProjects() throws {
    for _ in 1...100 {
      let projects = try Project.all()
      let project = projects.random
      if let project = project {
        let featuredProjectObject = try FeaturedProject(project_id: project.assertExists(), duration: 86400)
        try? featuredProjectObject.save()
        console.print("~~~~ Saved Featured Project ~~~~")
      }
    }
  }
  
  func createConnections() throws {
    let dev = try User.makeQuery().filter("email", "investinginme.dev@gmail.com").first()
    let users = try User.makeQuery().filter("email", .notEquals, "investinginme.dev@gmail.com").all()
    let vals = [true, false]
    
    for i in 0...users.count / 2 {
      // We'll add half based on the dev, and the other half based on some
      let connection = try Connection(inviter_id: dev!.assertExists(), invitee_id: users[i].assertExists(), accepted: vals.random!, message: "This is my message")
      try? connection.save()
      console.print("~~~~ Saved Connection ~~~~")
    }
  
    for i in (users.count / 2)+1...users.count - 1 {
      let connection = try Connection(inviter_id: users[i].assertExists(), invitee_id: dev!.assertExists(), accepted: vals.random!, message: "This is my message")
      try? connection.save()
      console.print("~~~~ Saved Connection ~~~~")
    }
  }
  
  func createRoles() throws {
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
  }
  
  func createCategories() throws {
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
  }
  
  func run(arguments: [String]) throws {
    if environment == .development {
      try Asset.makeQuery().delete()
      try FeaturedProject.makeQuery().delete()
      try Project.makeQuery().delete()
      try Connection.makeQuery().delete()
      try Notification.makeQuery().delete()
      try User.makeQuery().delete()
      try Role.makeQuery().delete()
      try Category.makeQuery().delete()
      // Re-create
      try createRoles()
      try createCategories()
      try createUser()
      try createProjects()
      try createAssets()
      try createFeaturedProjects()
      try createConnections()
    } else if environment == .production {
      try createRoles()
      try createCategories()
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
