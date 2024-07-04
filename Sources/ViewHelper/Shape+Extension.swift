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
