import IdentifiedCollections
import SwiftUI

struct WebToonNotificationItemView: View {
  let itemList: [NewAndNowCore.State.NotificationItem]
  
  var body: some View {
    ScrollView(.horizontal) {
      LazyHStack {
        ForEach(itemList) { notificationItem in
          HStack {
            LazyImage(url: notificationItem.thumbnail) { image in
              image
                .resizable()
                .clipShape(Circle())
                .frame(width: 32, height: 32)
            } placeholder: {
              Color.clear
            }

            Text(compareWithDate(notificationItem.releaseDate))
              .padding(.trailing)
              .foregroundStyle(.manta.white)
          }
          .padding(4)
          .background {
            Capsule()
          }
        }
      }
      .frame(height: 40)
    }
    .scrollIndicators(.hidden)
  }
}

private func compareWithDate(_ date: Date) -> String {
  let calendar = Calendar.current
  
  let components = calendar.dateComponents([.day], from: comparedDate)
  guard let diff = components.day else { return "" }
  return diff <= 0 ? "Read now" : "D - \(diff)"
}

private let comparedDate: Date = {
  var calendar = Calendar.current
  calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
  let dateComponents = DateComponents(year: 2024, month: 7, day: 3)
  return calendar.date(from: dateComponents)!
}()

@available(iOS 17.0, *)
#Preview {
  WebToonNotificationItemView(
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
  )
}
