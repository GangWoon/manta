import SwiftUI

public struct AnimatedUnderlineTabBar<Content: View, Item: Hashable>: View {
  @Namespace private var namespace
  
  var spacing: CGFloat
  @Binding var currentTab: Item
  var itemList: [Item]
  var underlineHeight: CGFloat
  var tabBarItem: (Item) -> Content
  
  public init(
    spacing: CGFloat = 20,
    currentTab: Binding<Item>,
    itemList: [Item],
    underlineHeight: CGFloat = 2,
    tabBarItem: @escaping (Item) -> Content
  ) {
    self.spacing = spacing
    self._currentTab = currentTab
    self.itemList = itemList
    self.underlineHeight = underlineHeight
    self.tabBarItem = tabBarItem
  }
  
  public var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: spacing) {
        let list = Array(zip(itemList.indices, itemList))
        ForEach(list, id: \.0) { index, item in
          TabBarItem(
            currentTab: $currentTab,
            tab: item,
            namespace: namespace.self,
            content: tabBarItem
          )
        }
      }
    }
  }
}

struct TabBarItem<Content, Item>: View where Content: View, Item: Hashable {
  @Environment(\.underlineHeight) private var underlineHeight: CGFloat
  
  @Binding var currentTab: Item
  let tab: Item
  let namespace: Namespace.ID
  let content: (Item) -> Content
  
  var body: some View {
    VStack(spacing: 4) {
      content(tab)
      
      if currentTab == tab {
        Color.black
          .frame(height: underlineHeight)
          .matchedGeometryEffect(
            id: "underline",
            in: namespace,
            properties: .frame
          )
      } else {
        Color.clear
          .frame(height: underlineHeight)
      }
    }
    .animation(.easeInOut, value: currentTab)
    .onTapGesture { currentTab = tab }
  }
}

struct UnderlineHeightKey: @preconcurrency EnvironmentKey {
  @MainActor static var defaultValue: CGFloat = 2
}
extension EnvironmentValues {
  public var underlineHeight: CGFloat {
    get { self[UnderlineHeightKey.self] }
    set { self[UnderlineHeightKey.self] = newValue }
  }
}

@available(iOS 18.0, *)
#Preview {
  @Previewable @State var selected: String = "ABCD1234"
  
  AnimatedUnderlineTabBar(
    currentTab: $selected,
    itemList: ["ABCD1234" ,"D", "CCC32"]
  ) { item in
    Text(item)
  }
  .environment(\.underlineHeight, 1.5)
}
