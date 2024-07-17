import SwiftUI

public struct AnimatedUnderlineTabBar<Content: View, Underline: View, Item: Hashable>: View {
  @Namespace private var namespace
  
  var spacing: CGFloat
  @Binding var currentTab: Item
  var items: [Item]
  var tabBarItem: (Item) -> Content
  var underline: () -> Underline
  
  public init(
    spacing: CGFloat = 20,
    currentTab: Binding<Item>,
    items: [Item],
    tabBarItem: @escaping (Item) -> Content,
    underline: @escaping () -> Underline
  ) {
    self.spacing = spacing
    self._currentTab = currentTab
    self.items = items
    self.tabBarItem = tabBarItem
    self.underline = underline
  }
  
  public var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: spacing) {
        let list = Array(zip(items.indices, items))
        ForEach(list, id: \.0) { index, item in
          TabBarItem(
            currentTab: $currentTab,
            tab: item,
            namespace: namespace.self,
            content: tabBarItem,
            underline: underline
          )
        }
      }
    }
  }
}

struct TabBarItem<Content, Underline,Item>: View where Content: View, Underline: View, Item: Hashable {
  @Binding var currentTab: Item
  let tab: Item
  let namespace: Namespace.ID
  let content: (Item) -> Content
  let underline: () -> Underline
  
  @State private var underlineHeight: CGFloat = .zero
  
  var body: some View {
    VStack(spacing: 4) {
      content(tab)
      
      if currentTab == tab {
        underline()
          .matchedGeometryEffect(
            id: "underline",
            in: namespace,
            properties: .frame
          )
          .readSize { underlineHeight = $0.height }
      } else {
        Color.clear
          .frame(height: underlineHeight)
      }
    }
    .animation(.easeInOut, value: currentTab)
    .simultaneousGesture(
      TapGesture()
        .onEnded { currentTab = tab }
    )
  }
}

//@available(iOS 18.0, *)
//#Preview {
//  @Previewable @State var selected: String = "ABCD1234"
//  AnimatedUnderlineTabBar(
//    currentTab: $selected,
//    itemList: ["ABCD", "efg"]) { item in
//      Text(item)
//    } underline: {
//      Color.black.frame(height: 2)
//    }
//}
