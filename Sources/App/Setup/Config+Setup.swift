import FluentProvider
import PostgreSQLProvider

extension Config {
  public func setup() throws {
    // allow fuzzy conversions for these types
    // (add your own types here)
    Node.fuzzy = [Row.self, JSON.self, Node.self]
    
    try setupProviders()
    try setupPreparations()
    setupCommands()
  }
  
  /// Configure providers
  private func setupProviders() throws {
    try addProvider(FluentProvider.Provider.self)
    try addProvider(PostgreSQLProvider.Provider.self)
  }
  
  /// configures our custom commands that we have
  private func setupCommands() {
    addConfigurable(command: SeedCommand.init, name: "seed")
  }
  
  /// Add all models that should have their
  /// schemas prepared before the app boots
  private func setupPreparations() throws {
    preparations.append(Role.self)
    preparations.append(User.self)
    
    preparations.append(ProjectAsset.self)
  }
}
