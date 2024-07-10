import ComposableArchitecture
import SwiftUI

public struct WebToonNotificationItemListCore: Reducer {
  public struct State: Equatable {
    struct NotificationItem: Sendable, Equatable, Identifiable {
      public var id: UUID
      public var thumbnail: URL?
      public var releaseDate: Date
      
    }
    var isEmpty: Bool {
      itemList.isEmpty
    }
    var itemList: [NotificationItem]
    var scrollID: NotificationItem.ID?
  }
  
  public enum Action: Equatable, Sendable {
    
  }
  
  public var body: some ReducerOf<Self> {
    Reduce<State, Action> { state, action in
      return .none
    }
  }
}

extension WebToonNotificationItemListCore.State.NotificationItem: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.releaseDate < rhs.releaseDate
  }
}

struct WebToonNotificationItemListView: View {
  let store: StoreOf<WebToonNotificationItemListCore>
  private var viewStore: ViewStoreOf<WebToonNotificationItemListCore>
  
  init(store: StoreOf<WebToonNotificationItemListCore>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
  }
  
  var body: some View {
    // MARK: - Reducer macro를 사용할 경우 ForEach(viewStore.itemList)에서 경고 발생
    ScrollView(.horizontal) {
      ScrollViewReader { proxy in
        HStack {
          ForEach(viewStore.itemList) { notificationItem in
            HStack {
              LazyImage(url: notificationItem.thumbnail) { image in
                image
                  .resizable()
                  .clipShape(Circle())
                  .frame(width: 32, height: 32)
                
              } placeholder: {
                Color.clear
                  .frame(width: 32, height: 32)
                
              }
              .frame(width: 32, height: 32)
              
              Text(daysUntil(notificationItem.releaseDate))
                .padding(.trailing)
                .foregroundStyle(.manta.white)
            }
            .id(notificationItem.id)
            .padding(4)
            .background {
              Capsule()
                .fill(.manta.black)
            }
          }
        }
        .frame(height: 40)
        .onChange(of: viewStore.scrollID) {
          guard let id = $0 else { return }
          withAnimation { proxy.scrollTo(id) }
        }
      }
    }
    .scrollIndicators(.hidden)
    
  }
  
  private let comparedDate: Date = {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
    let dateComponents = DateComponents(year: 2024, month: 7, day: 3)
    return calendar.date(from: dateComponents)!
  }()
  
  private func daysUntil(_ date: Date) -> String {
    let calendar = Calendar.current
    let components = calendar
      .dateComponents([.day], from: comparedDate, to: date)
    guard let diff = components.day else { return "" }
    return diff <= 0 ? "Read now" : "D - \(diff)"
  }
}


@available(iOS 17.0, *)
#Preview {
  WebToonNotificationItemListView(
    store: .init(
      initialState: WebToonNotificationItemListCore.State(
        itemList: [
          .init(
            id: UUID(),
            thumbnail: URL(string: "https://github.com/GangWoon/manta/assets/48466830/8d4487b9-a8fc-4612-9444-b5c5dc1b19c7"),
            releaseDate: .now
          ),
          .init(
            id: UUID(),
            thumbnail: URL(string: "https://github.com/GangWoon/manta/assets/48466830/8d4487b9-a8fc-4612-9444-b5c5dc1b19c7"),
            releaseDate: .now
          ),
          .init(
            id: UUID(),
            thumbnail: URL(string: "https://github.com/GangWoon/manta/assets/48466830/8d4487b9-a8fc-4612-9444-b5c5dc1b19c7"),
            releaseDate: .now
          ),
        ]
      ),
      reducer: WebToonNotificationItemListCore.init
    )
  )
}
