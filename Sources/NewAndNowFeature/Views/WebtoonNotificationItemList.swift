import ComposableArchitecture
import ViewHelper
import SwiftUI

struct WebtoonNotificationItemList: View {
  typealias NotificationItem = NewAndNowCore.State.NotificationItem
  var notificationItems: [NotificationItem]
  var scrollID: NotificationItem.ID?
  var rowAction: (NotificationItem.ID) -> Void
  
  var body: some View {
    AutoScrollView(
      axis: .horizontal,
      anchor: .trailing,
      scrollID: scrollID
    ) {
      HStack {
        ForEach(notificationItems) { notificationItem in
          notificationRow(notificationItem)
            .onTapGesture { rowAction(notificationItem.id) }
        }
      }
    }
    .scrollIndicators(.hidden)
  }
  
  func notificationRow(_ item: NotificationItem) -> some View {
    HStack {
      thumnbail(item)
      
      Text(item.dDay)
        .padding(.trailing)
        .foregroundStyle(.manta.white)
    }
    .id(item.id)
    .padding(4)
    .background {
      Capsule()
        .fillAndStroke(
          fill: .manta.black,
          stroke: item.nowAvailable
          ? .palette
          : .transparent,
          lineWidth: 1.5
        )
    }
  }
  
  private func thumnbail(_ item: NotificationItem) ->  some View {
    LazyImage(url: item.thumbnail) { image in
      image
        .resizable()
        .clipShape(Circle())
        .frame(width: 32, height: 32)
    } placeholder: {
      Color.manta.slateGray
        .frame(width: 32, height: 32)
        .clipShape(Circle())
        .shimmering()
    }
    .frame(width: 32, height: 32)
    .overlay(alignment: .topTrailing) {
      if item.nowAvailable {
        newBadge
      }
    }
  }
  
  private var newBadge: some View {
    Text("N")
      .foregroundStyle(.manta.white)
      .font(.system(size: 6).bold())
      .padding(2)
      .background {
        Circle()
          .fill(Color.red)
          .overlay {
            Circle()
              .stroke(Color.manta.black, lineWidth: 2)
          }
      }
  }
}

extension Date {
  private static let calendar = {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
    return calendar
  }()
  
  static let comparedDate: Date = {
    let dateComponents = DateComponents(year: 2024, month: 7, day: 3)
    return calendar.date(from: dateComponents)!
  }()
  
  var daysDifference:  Int {
    let components = Self.calendar.dateComponents([.day], from: .comparedDate, to: self)
    return components.day ?? 0
  }
}

extension NewAndNowCore.State.NotificationItem: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.releaseDate < rhs.releaseDate
  }
}

private extension NewAndNowCore.State.NotificationItem {
  var nowAvailable: Bool {
    releaseDate.daysDifference <= 0
  }
  
  var dDay: String {
    let diff = releaseDate.daysDifference
    return diff <= 0 ? "Read now" : "D - \(diff)"
  }
}

#if DEBUG
let dates: [Date] = {
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
  WebtoonNotificationItemList(
    notificationItems: [
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
      )
    ],
    scrollID: nil,
    rowAction: { _ in }
  )
}
#endif
