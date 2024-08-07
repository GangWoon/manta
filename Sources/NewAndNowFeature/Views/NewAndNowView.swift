import ComposableArchitecture
import WebtoonDetailFeature
import SharedModels
import ViewHelper
import ApiClient
import SwiftUI

public struct NewAndNowView: View {
  @State private var turningPoint = CGFloat.zero
  @State private var categoryChangeThreshold: CGFloat = .zero
  @State private var isScrolling: Bool = false
  @State private var scrollID: UUID?
  
  @Namespace private var animation
  private let coordinateSpace = "ScrollView"
  
  @Perception.Bindable var store: StoreOf<NewAndNowCore>
  
  public init(store: StoreOf<NewAndNowCore>) {
    self.store = store
  }
  
  public var body: some View {
    WithPerceptionTracking {
      VStack(spacing: 0) {
        dashboard
          .padding(.horizontal, 16)
        
        if store.isHeaderVisible && !store.notificationItems.isEmpty {
          WebtoonNotificationItemList(
            notificationItems: store.notificationItems,
            scrollID: store.notificationItemScrollID,
            rowAction: { id in
              store.send(.notificationItemTapped(id))
            }
          )
          .frame(height: 48)
        }
        
        scrollViewHeader
          .padding(.horizontal, 16)
          .background {
            VStack(spacing: 0) {
              Color.manta.deepGray
              Color.manta.gray
                .frame(height: 1)
            }
          }
        
        scrollView
          .padding(.horizontal, 16)
      }
      .onChange(of: store.webtoons) {
        categoryChangeThreshold = Array($0).categoryChangeThreshold
      }
      .task { await store.send(.prepare).finish() }
      .animation(.easeInOut, value: store.isHeaderVisible)
      .background { Color.manta.deepGray.ignoresSafeArea() }
      .overlay {
        /// NOTE: Multiple inserted views 경고가 발생하지만, 뷰에 직접적인 문제는 발생하지 않습니다.
        /// ZStack 내부에 분기문을 사용하면 해당 경고를 해결할 수 있지만,
        /// 스크롤 뷰의 위치를 현 시점에서 제어할 수 없기에 나중 작업으로 우선순위를 미루도록 하겠습니다.
        let store = store.scope(state: \.selectedWebtoonRow, action: \.webtoonDetail)
        if let store {
          WebtoonDetailView(
            store: store,
            animation: animation
          )
        }
      }
      .alert($store.scope(state: \.alert, action: \.alert))
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
      .font(.title2.bold())
    }
    .foregroundStyle(.manta.white)
  }
  
  private var scrollViewHeader: some View {
    HStack {
      AnimatedUnderlineTabBar(
        currentTab: $store.selectedReleaseStatus,
        items: store.releaseCategories
      ) { item in
        Text(item.title)
          .foregroundStyle(
            store.selectedReleaseStatus == item
            ? Color.manta.white
            : Color.manta.stealGray
          )
          .onTapGesture {
            scrollID = store.state.scrollID(for: item)
            isScrolling = true
          }
      } underline: {
        Color.manta.white
          .frame(height: 2)
      }
      
      Spacer()
    }
  }
  
  private var scrollView: some View {
    GeometryReader { outer in
      let outerHeight = outer.size.height
      AutoScrollView(anchor: .top, scrollID: scrollID) {
        VStack {
          let list = Array(
            zip(
              store.webtoonRows.ids,
              store.scope(state: \.webtoonRows, action: \.webtoonRows)
            )
          )
          ForEach(list, id: \.0) { id, store in
            WebtoonRow(store: store, animation: animation)
              .padding(.top, 16)
              .id(id)
            /// store.id로 했을 경우 스크롤 되지 않는 이슈 발생
          }
        }
        .background { scrollDirectionTracker(outerHeight) }
        .readScrollOffset(coordinateSpace) { offset in
          guard !isScrolling else { return }
          let value = offset > categoryChangeThreshold
          ? NewAndNowCore.State.ReleaseStatus.newArrivals
          : .comingSoon
          store.send(.binding(.set(\.selectedReleaseStatus, value)))
        }
      }
      .coordinateSpace(name: coordinateSpace)
      .simultaneousGesture(scrollStausTracker)
      .scrollIndicators(.hidden)
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
    let thresholdScrollDistance: CGFloat = 50
    if
      (store.isHeaderVisible && newValue > oldValue)
        || (!store.isHeaderVisible && newValue < oldValue)
    {
      turningPoint = newValue
    }
    if
      (store.isHeaderVisible && turningPoint > newValue)
        || (!store.isHeaderVisible && (newValue - turningPoint) > thresholdScrollDistance)
    {
      store.send(.binding(.set(\.isHeaderVisible,  newValue > turningPoint)))
    }
  }
  
  private var scrollStausTracker: some Gesture {
    DragGesture()
      .onChanged { _ in
        isScrolling = true
        scrollID = nil
      }
      .onEnded { _ in
        isScrolling = false
      }
  }
}

private extension [Webtoon] {
  var categoryChangeThreshold: CGFloat {
    filter { $0.releaseDate != nil }
      .map { $0.episodes.isEmpty ? 500.0 : 600 }
      .reduce(into: 0, +=)
  }
}

private extension NewAndNowCore.State {
  func scrollID(for releaseStatus: ReleaseStatus) -> WebtoonCore.State.ID? {
    webtoonRows
      .filter { $0.releaseStatus == releaseStatus }
      .first?
      .id
  }
}

extension NewAndNowCore.State.ReleaseStatus {
  fileprivate var title: String {
    switch self {
    case .comingSoon:
      return "Coming soon"
    case .newArrivals:
      return "New arrivals"
    }
  }
}

#if DEBUG
#Preview {
  NewAndNowView(
    store: Store(
      initialState: NewAndNowCore.State()
    ) {
      NewAndNowCore()
    }
  )
}
#endif
