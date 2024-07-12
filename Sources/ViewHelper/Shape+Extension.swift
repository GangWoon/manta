import SwiftUI

extension Shape {
  public func fillAndStroke<Fill: ShapeStyle, Stroke: ShapeStyle>(
    fill: Fill,
    stroke: Stroke,
    lineWidth: CGFloat = 1
  ) -> some View {
    ZStack {
      self.fill(fill)
      self.stroke(stroke, lineWidth: lineWidth)
    }
  }
}

extension ShapeStyle where Self == AngularGradient {
  public static var palette: AngularGradient {
    AngularGradient(
      gradient: Gradient(stops: [
        .init(color: .blue, location: 0.0),
        .init(color: .purple, location: 0.2),
        .init(color: .red, location: 0.4),
        .init(color: .mint, location: 0.5),
        .init(color: .indigo, location: 0.7),
        .init(color: .pink, location: 0.9),
        .init(color: .blue, location: 1.0),
      ]),
      center: .center,
      startAngle: Angle(radians: .zero),
      endAngle: Angle(radians: .pi * 2)
    )
  }

  public static var transparent: AngularGradient {
    AngularGradient(
      gradient: Gradient(stops: []),
      center: .center,
      startAngle: Angle(radians: .zero),
      endAngle: Angle(radians: .pi * 2)
    )
  }
}
