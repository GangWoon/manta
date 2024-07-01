import ComposableArchitecture
import ApiClient
import SwiftUI

public struct NewAndNowView: View {
  let store: StoreOf<NewAndNowCore>
  // MARK: - ViewState
  @State private var showingHeader = true
  @State private var turningPoint = CGFloat.zero
  private let thresholdScrollDistance: CGFloat = 50
  private let coordinateSpace = "ScrollView"
  
  
  public init(store: StoreOf<NewAndNowCore>) {
    self.store = store
  }
  
  public var body: some View {
    WithPerceptionTracking {
      VStack(spacing: 0) {
        dashboard
          .padding(.horizontal, 16)
        
        if showingHeader {
          notificationList
        }
        
        scrollViewHeader
          .padding(.horizontal, 16)
        
        
        scrollView
          .padding(.horizontal, 16)
      }
      .animation(.easeInOut, value: showingHeader)
      .task { await store.send(.prepare).finish() }
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
    .background(Color.white)
  }
  
  private var notificationList: some View {
    HStack {
      Text("ABCD")
      Text("ABCD")
      Text("ABCD")
    }
  }
  private var scrollView: some View {
    GeometryReader { outer in
      let outerHeight = outer.size.height
      
      ScrollView(showsIndicators: false) {
        LazyVStack(spacing: 24) {
          ForEach(
            store.scope(state: \.webToonList, action: \.webToonList),
            content: WebToonRow.init
          )
        }
        .background {
          GeometryReader { proxy in
            let contentHeight = proxy.size.height
            let minY = max(
              min(0, proxy.frame(in: .named(coordinateSpace)).minY),
              outerHeight - contentHeight
            )
            Color.clear
              .onChange(of: minY) { newValue in
                if (showingHeader && newValue > minY) || (!showingHeader && newValue < minY) {
                  turningPoint = newValue
                }
                
                if (showingHeader && turningPoint > newValue) || (!showingHeader && (newValue - turningPoint) > thresholdScrollDistance) {
                  showingHeader = newValue > turningPoint
                }
              }
          }
        }
      }
      .coordinateSpace(name: coordinateSpace)
    }
    .padding(.top, 1)
  }
}
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
