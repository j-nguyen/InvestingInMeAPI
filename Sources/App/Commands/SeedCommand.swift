import Vapor
import HTTP
import Console
import Random
import LoremSwiftum

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
  
  init(console: ConsoleProtocol, environment: Environment) {
    self.console = console
    self.environment = environment
  }
  
  func createUser() throws {
    // Create Dev Account
    let user = try User(
      google_id: "115087936934019172257",
      email: "investinginme.dev@gmail.com",
      name: "Dev InvestingInMe",
      picture: "https://lh4.googleusercontent.com/-odK3p3pgzIc/AAAAAAAAAAI/AAAAAAAAAAA/ACSILjUEWrHe0j_9GxV1yT2oVaObU557-Q/s96-c/photo.jpg",
      email_verification: true
    )
    user.description = Lorem.sentence
    user.experience_and_credentials = Lorem.paragraph
    try user.save()
    console.print ("~~~~~ Saved User: \(user.name) ~~~~~~")
    
    // Setup the user projects now
    let categories = Category.Group.allValues
    let roles = Role.Group.allValues
    
    // Creates all projects to fill for categories and roles
    for category in categories {
      guard let categoryType = Category.Group(rawValue: category) else { return }
      for role in roles {
        guard let roleType = Role.Group(rawValue: role) else { return }
        let project = try Project(
          user_id: user.assertExists(),
          name: Lorem.title,
          category_id: categoryType.category().assertExists(),
          role_id: roleType.role().assertExists(),
          project_description: Lorem.paragraph,
          description_needs: Lorem.paragraph
        )
        try project.save()
        console.print("~~~~~~ Project Saved: \(project.name) ~~~~~~~")
      }
    }
  }
  
  func createProjects() throws {
    
    // Setup the user projects now
    let categories = Category.Group.allValues
    let roles = Role.Group.allValues
    
    // Creates all projects to fill for categories and roles
    for category in categories {
      guard let categoryType = Category.Group(rawValue: category) else { return }
      guard let randomRole = Role.Group(rawValue: roles.random ?? "") else { return }
      
      // we can set-up the user here
      let user = try User(
        google_id: "\(URandom.makeInt())",
        email: "\(category)-email@example.com",
        name: Lorem.name,
        picture: "https://lh4.googleusercontent.com/-odK3p3pgzIc/AAAAAAAAAAI/AAAAAAAAAAA/ACSILjUEWrHe0j_9GxV1yT2oVaObU557-Q/s96-c/photo.jpg",
        email_verification: true
      )
      user.role_id = try randomRole.role().assertExists()
      
      try user.save()
      console.print ("~~~~~ Saved User: \(user.name) ~~~~~~")
      
      for role in roles {
        guard let roleType = Role.Group(rawValue: role) else { return }
        let project = try Project(
          user_id: user.assertExists(),
          name: Lorem.title,
          category_id: categoryType.category().assertExists(),
          role_id: roleType.role().assertExists(),
          project_description: Lorem.paragraph,
          description_needs: Lorem.paragraph
        )
        try project.save()
        console.print("~~~~~~ Project Saved: \(project.name) ~~~~~~~")
      }
    }
  }
  
  func createAssets() throws {
    let projects = try Project.all()
    // CReate the assets
    for project in projects {
      let assetProfile = try Asset(
        project_id: project.assertExists(),
        file_type: "Image",
        url: project.name.generatePlaceholder(),
        file_name: "file-\(project.assertExists().int!)",
        file_size: 2324,
        project_icon: true
      )
      try assetProfile.save()
      console.print("~~~~ Saved App Profile Icon ~~~~")
      
      for i in 1...3 {
        // Set the beginning to have the icon true and the rest not
        let assetObj = try Asset(
          project_id: project.assertExists(),
          file_type: "Image",
          url: "https://via.placeholder.com/350x150",
          file_name: "\(i)-Placeholder-Image",
          file_size: 2324,
          project_icon: false
        )
        try assetObj.save()
        console.print("~~~~ Saved Picture ~~~~~")
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
    if environment == .development || environment == .test {
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
    self.init(console: console, environment: config.environment)
  }
}
