import SwiftUI

extension View {
  public func readSize(_ onChange: @escaping (CGSize) -> Void) -> some View {
    background {
      GeometryReader { proxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: proxy.size)
      }
    }
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

struct SizePreferenceKey: @preconcurrency PreferenceKey {
  @MainActor static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
  }
}
