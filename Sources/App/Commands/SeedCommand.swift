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
  
  init(console: ConsoleProtocol, environment: Environment, seeds: Config?) {
    self.console = console
    self.environment = environment
    self.user = seeds?["user"]
  }
  
  func createUsers() throws {
    if let user = user {
      for i in 1...10 {
        var email: String = try String(i) + user.get("email")
        let userObject = try User.init(google_id: URandom().makeInt(), email: email, name: user.get("name"), picture: user.get("picture"), email_verification: user.get("email_verification"))
        var tempVariable:[String] = try user.get("phone_number")
        userObject.phone_number = tempVariable.random ?? ""
      
        
        try userObject.save()
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
