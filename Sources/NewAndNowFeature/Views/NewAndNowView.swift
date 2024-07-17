import ComposableArchitecture
import ViewHelper
import ApiClient
import SwiftUI

public struct NewAndNowView: View {
  // MARK: - ViewState
  @State private var showingHeader = true
  @State private var turningPoint = CGFloat.zero
  private let thresholdScrollDistance: CGFloat = 50
  private let coordinateSpace = "ScrollView"
  
  @State private var scrollValue: ScrollValue = .init(isScrolling: false)
  
  @Perception.Bindable var store: StoreOf<NewAndNowCore>
  
  public init(store: StoreOf<NewAndNowCore>) {
    self.store = store
  }
  
  public var body: some View {
    WithPerceptionTracking {
      VStack(spacing: 0) {
        dashboard
          .padding(.horizontal, 16)
        
        if showingHeader && !store.notificationItemList.isEmpty {
          WebToonNotificationItemListView(
            store: store
              .scope(state: \.notificationItemList, action: \.notificationItemList)
          )
          .frame(height: 48)
        }
        
        scrollViewHeader
          .padding(.horizontal, 16)
          .background(alignment: .bottom) {
            Color.gray
              .frame(height: 1)
          }
        
        scrollView
          .padding(.horizontal, 16)
      }
      .background { Color.manta.deepGray.ignoresSafeArea() }
      .animation(.easeInOut, value: showingHeader)
      .task { await store.send(.prepare).finish() }
      .bind($showingHeader, to: $store.forceShowingHeader)
    }
  }
  
  private var dashboard: some View {
    VStack {
      HStack {
        Text("New & Now")
        Spacer()
        Image(systemName: "text.magnifyingglass")
        Image(systemName: "person.crop.circle")
      }
      .font(.system(size: 22).bold())
    }
    .foregroundStyle(.manta.white)
  }
  
  private var scrollViewHeader: some View {
    AnimatedUnderlineTabBar(
      currentTab: $store.selectedReleaseStatus,
      itemList: store.scrollCategoryList
    ) { item in
      Text(item.title)
        .foregroundStyle(
          store.selectedReleaseStatus == item
          ? Color.manta.white
          : Color.manta.lightGray
        )
        .onTapGesture {
          scrollValue.scrollID = store.state.scrollID(for: item)
          scrollValue.isScrolling = true
        }
    } underline: {
      Color.manta.white
        .frame(height: 2)
    }
  }
  
  private var scrollView: some View {
    GeometryReader { outer in
      let outerHeight = outer.size.height
      
      ScrollViewReader { proxy in
        ScrollView(showsIndicators: false) {
          VStack {
            let list = Array(
              zip(
                store.webToonList.ids,
                store.scope(state: \.webToonList, action: \.webToonList)
              )
            )
            ForEach(list, id: \.0) { id, store in
              WebToonRow(store: store)
                .padding(.top, 16)
                .id(id)
            }
          }
          .background { scrollDirectionTracker(outerHeight) }
          .readScrollOffset(coordinateSpace) {
            guard !scrollValue.isScrolling else { return }
            let value = $0 > store.categoryChangeHeight
            ? WebToonCore.State.ReleaseStatus.newArrivals
            : .comingSoon
            store.send(.binding(.set(\.selectedReleaseStatus, value)))
          }
        }
        .simultaneousGesture(scrollStausTracker)
        .onChange(of: scrollValue) { newValue in
          guard let scrollID = newValue.scrollID else { return }
          withAnimation(.easeIn(duration: 1)) { proxy.scrollTo(scrollID, anchor: .top) }
          if newValue.isScrolling {
            Task {
              try await Task.sleep(for: .seconds(1))
              scrollValue.isScrolling = false
            }
          }
        }
      }
      .coordinateSpace(name: coordinateSpace)
    }
    .padding(.top, 1)
  }
  
  private func scrollDirectionTracker(_ outerHeight: CGFloat) -> some View {
    GeometryReader { proxy in
      let contentHeight = proxy.size.height
      let minY = max(
        min(0, proxy.frame(in: .named(coordinateSpace)).minY),
        outerHeight - contentHeight
      )
      Color.clear
        .onChange(of: minY) { newValue in
          updateShowingHeader(oldValue: minY, newValue: newValue)
        }
    }
  }
  
  private func updateShowingHeader(oldValue: CGFloat, newValue: CGFloat) {
    if
      (showingHeader && newValue > oldValue)
      || (!showingHeader && newValue < oldValue)
    {
      turningPoint = newValue
    }
    if
      (showingHeader && turningPoint > newValue)
      || (!showingHeader && (newValue - turningPoint) > thresholdScrollDistance)
    {
      showingHeader = newValue > turningPoint
    }
  }
  
  private var scrollStausTracker: some Gesture {
    DragGesture()
      .onChanged { _ in
        scrollValue.isScrolling = true
        scrollValue.scrollID = nil
      }
      .onEnded { _ in
        scrollValue.isScrolling = false
      }
  }
}

private extension NewAndNowView {
  struct ScrollValue: Equatable {
    var isScrolling: Bool
    var scrollID: UUID?
  }
  
  struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
      
    }
  }
}

extension WebToonCore.State.ReleaseStatus {
  fileprivate var title: String {
    switch self {
    case .comingSoon:
      return "Coming soon"
    case .newArrivals:
      return "New arrivals"
    }
  }
}

#Preview {
  NewAndNowView(
    store: Store(initialState: NewAndNowCore.State()) {
      NewAndNowCore()
    }
  )
}
