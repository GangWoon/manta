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

// MARK: - Swift 6.0
//struct SizePreferenceKey: @preconcurrency PreferenceKey {
struct SizePreferenceKey: PreferenceKey {
  @MainActor static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
  }
}
