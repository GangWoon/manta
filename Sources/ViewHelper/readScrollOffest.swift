import SwiftUI

extension View {
  public func readScrollOffset(
    axis: Axis = .vertical,
    _ coordinateSpace: AnyHashable? = nil,
    _ closure: @escaping (CGFloat) -> Void
  ) -> some View {
    self
      .background {
        GeometryReader { proxy in
          if let coordinateSpace {
            let value = axis == .vertical
            ? -proxy.frame(in: .named(coordinateSpace)).minY
            : -proxy.frame(in: .named(coordinateSpace)).minX
            Color.clear
              .preference(
                key: ScrollOffsetKey.self,
                value: value
              )
          } else {
            let value = axis == .vertical
            ? -proxy.frame(in: .global).minY
            : -proxy.frame(in: .global).minX
            Color.clear
              .preference(
                key: ScrollOffsetKey.self,
                value: value
              )
          }
        }
      }
      .onPreferenceChange(ScrollOffsetKey.self) {
        closure($0)
      }
  }
}

struct ScrollOffsetKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(
    value: inout CGFloat,
    nextValue: () -> CGFloat
  ) {
  }
}
