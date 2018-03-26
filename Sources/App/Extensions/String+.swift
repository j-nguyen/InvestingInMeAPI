import Foundation
import Random

/// Extension swift
extension String {
  /// Generates a placeholder url for us, with proper background colors
  public func generatePlaceholder() -> String {
    // Gets the first letter of the string
    let letter = trim().uppercased().first ?? "?"
    
    // We'll generate our own temporary colours for us to use
    let colors: [(background: String, foreground: String)] = [
      ("F44336", "FFFFFF"), ("3498DB", "FFFFFF"), ("F1C40F", "000000"), ("E74C3C", "FFFFFF"),
      ("8E44AD", "FFFFFF"), ("2C3E50", "FFFFFF"), ("1ABC9C", "FFFFFF"), ("F0932B", "000000"),
      ("BADC58", "000000"), ("EB4D4B", "FFFFFF"), ("82CCDD", "000000"), ("3D3D3D", "FFFFFF")
    ]
    
    let color = colors.random ?? ("F44336", "FFFFFF")
    
    return "https://via.placeholder.com/100/\(color.background)/\(color.foreground)/?text=\(letter)"
  }
}
