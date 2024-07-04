import SwiftUI

public struct ScaleButtonStyle: ButtonStyle {
  var pressedScale: CGFloat
  
  public init(pressedScale: CGFloat = 1.02) {
    self.pressedScale = pressedScale
  }
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 1 : 1.02)
      .animation(.easeInOut, value: configuration.isPressed)
  }
}
