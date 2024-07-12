import ComposableArchitecture
import ViewHelper
import SwiftUI

public struct WebToonNotificationItemListCore: Reducer {
  public struct State: Equatable, Sendable {
    var isEmpty: Bool {
      itemList.isEmpty
    }
    
    var scrollID: NotificationItem.ID?
    var itemList: [NotificationItem]
    struct NotificationItem: Sendable, Equatable, Identifiable {
      public var id: UUID
      public var thumbnail: URL?
      public var releaseDate: Date
    }
    
    mutating func removeItem(with id: NotificationItem.ID) {
      if let index = self.itemList.firstIndex(where: { $0.id == id }) {
        itemList.remove(at: index)
      }
    }
  }
  
  public enum Action: Equatable, Sendable {
    
  }
  
  public func reduce(
    into state: inout State,
    action: Action
  ) -> Effect<Action> {
    .none
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
              .overlay(alignment: .topTrailing) {
                if notificationItem.nowAvailable {
                  Text("N")
                    .foregroundStyle(.manta.white)
                    .font(.system(size: 6).bold())
                    .padding(2)
                    .background {
                      Circle()
                        .fill(Color.red)
                        .overlay {
                          Circle()
                            .stroke(Color.black, lineWidth: 2)
                        }
                    }
                }
              }
              
              Text(notificationItem.dDay)
                .padding(.trailing)
                .foregroundStyle(.manta.white)
            }
            .id(notificationItem.id)
            .padding(4)
            .background {
              Capsule()
                .fillAndStroke(
                  fill: .black,
                  stroke: notificationItem.nowAvailable
                  ? .palette
                  : .transparent,
                  lineWidth: 1.5
                )
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
}

private let comparedDate: Date = {
  var calendar = Calendar.current
  calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
  let dateComponents = DateComponents(year: 2024, month: 7, day: 3)
  return calendar.date(from: dateComponents)!
}()

extension WebToonNotificationItemListCore.State.NotificationItem {
  var nowAvailable: Bool {
    daysDifference(from: comparedDate, to: releaseDate) <= 0
  }
  
  var dDay: String {
    let diff = daysDifference(from: comparedDate, to: releaseDate)
    return diff <= 0 ? "Read now" : "D - \(diff)"
  }
  
  private func daysDifference(from startDate: Date, to endDate: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: startDate, to: endDate)
    return components.day ?? 0
  }
}

#if DEBUG
var dates: [Date] = {
  var calendar = Calendar.current
  calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
  return [
    DateComponents(year: 2024, month: 7, day: 3),
    DateComponents(year: 2024, month: 7, day: 5),
    DateComponents(year: 2024, month: 7, day: 13)
  ]
    .compactMap { calendar.date(from: $0) }
}()

@available(iOS 17.0, *)
#Preview {
  WebToonNotificationItemListView(
    store: .init(
      initialState: WebToonNotificationItemListCore.State(
        itemList: [
          .init(
            id: UUID(),
            thumbnail: URL(string: "https://github.com/GangWoon/manta/assets/48466830/8d4487b9-a8fc-4612-9444-b5c5dc1b19c7"),
            releaseDate: dates[0]
          ),
          .init(
            id: UUID(),
            thumbnail: URL(string: "https://github.com/GangWoon/manta/assets/48466830/8d4487b9-a8fc-4612-9444-b5c5dc1b19c7"),
            releaseDate: dates[1]
          ),
          .init(
            id: UUID(),
            thumbnail: URL(string: "https://github.com/GangWoon/manta/assets/48466830/8d4487b9-a8fc-4612-9444-b5c5dc1b19c7"),
            releaseDate: dates[2]
          ),
        ]
      ),
      reducer: WebToonNotificationItemListCore.init
    )
  )
}
#endif

