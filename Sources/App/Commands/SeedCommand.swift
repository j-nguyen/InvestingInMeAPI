import Vapor
import HTTP
import Console

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
  }
}

// MARK: ConfigInitializable
extension SeedCommand: ConfigInitializable {
  convenience init(config: Config) throws {
    let console = try config.resolveConsole()
    self.init(console: console, environment: config.environment)
  }
}
