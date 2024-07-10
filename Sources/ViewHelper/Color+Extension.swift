import SwiftUI

extension Color {
  public init(hex: String) {
    var hexString = hex
    if hexString.hasPrefix("#") {
      hexString = String(hexString.dropFirst())
    }
    
    let scanner = Scanner(string: hexString)
    var rgbValue: UInt64 = 0
    scanner.scanHexInt64(&rgbValue)
    
    let red = Double((rgbValue & 0xff0000) >> 16) / 255.0
    let green = Double((rgbValue & 0x00ff00) >> 8) / 255.0
    let blue = Double(rgbValue & 0x0000ff) / 255.0
    
    self.init(red: red, green: green, blue: blue)
  }
}

public struct Manta {
  public let lightGray = Color(hex: "#6b6e75")
  public let gray = Color(hex: "#757e7d")
  public let deepGray = Color(hex: "#1b1d20")
  public let white = Color(hex: "#ffffff")
  public let black = Color(hex: "#000000")
  public let blackA05 = Color(hex: "#000000").opacity(0.6)
}

extension Color {
  public static let manta: Manta = .init()
}

extension ShapeStyle where Self == Color {
  public static var manta: Manta {
    Color.manta
  }
}
