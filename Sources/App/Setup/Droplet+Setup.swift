@_exported import Vapor

var drop: Droplet?

extension Droplet {
  public func setup() throws {
    try setupRoutes()
    // Do any additional droplet setup
    drop = self
  }
}
