import SwiftUI

struct BadgeStyle: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.caption2).bold()
      .foregroundStyle(.manta.white)
      .padding(.vertical, 1)
      .padding(.horizontal, 2)
      .background {
        RoundedRectangle(cornerRadius: 4)
          .fill(.manta.gray)
      }
  }
}

extension View {
  public func badge() -> some View {
    modifier(BadgeStyle())
  }
}
