import SwiftUI

public struct AutoScrollView<Content: View, ID: Hashable>: View {
  var axis: Axis.Set
  var scrollID: ID?
  var anchor: UnitPoint?
  var contents: () -> Content
  
  public init(
    axis: Axis.Set = .vertical,
    anchor: UnitPoint?,
    scrollID: ID?,
    contents: @escaping () -> Content
  ) {
    self.axis = axis
    self.anchor = anchor
    self.scrollID = scrollID
    self.contents = contents
  }
  
  public var body: some View {
    ScrollViewReader { proxy in
      ScrollView(axis) {
        contents()
      }
      .onChange(of: scrollID) {
        guard let id = $0 else { return }
        withAnimation {
          proxy.scrollTo(id, anchor: anchor)
        }
      }
    }
  }
}
