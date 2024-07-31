import SwiftUI
import Shimmer

extension View {
  public func redactedShimmering(_ isActive: Bool) -> some View {
    redacted(reason: isActive ? .placeholder : [])
      .shimmering(active: isActive)
  }
}
