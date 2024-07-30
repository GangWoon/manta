import SharedModels
import ViewHelper
import Shimmer
import SwiftUI

struct WebtoonDetailRow: View {
  @State private var isShimmering: Bool = false
  var episode: Webtoon.Episode
  
  var body: some View {
    HStack {
      LazyImage(url: episode.thumbnail) { image in
        image
          .resizable()
          .scaledToFit()
          .frame(width: 80, height: 80)
          .onAppear { isShimmering = false }
      } placeholder: {
        Color.gray
          .frame(width: 80, height: 80)
          .shimmering()
          .onAppear { isShimmering = true }
      }
      .clipShape(RoundedRectangle(cornerRadius: 10))

      VStack(alignment: .leading) {
        Text(episode.title)
          .redactedShimmering(isShimmering)
          .font(.subheadline).bold()
        
        Text(dateFormatter.string(from: episode.releaseDate))
          .redactedShimmering(isShimmering)
          .foregroundStyle(.manta.lightGray)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 2) {
        let flag = episode.accessType != "FREE"
        Text(episode.accessType)
          .foregroundStyle(flag ? .indigo : .manta.white)
        
        if flag {
          Text("Only")
            .foregroundStyle(.indigo)
        }
      }
      .redactedShimmering(isShimmering)
    }
    .foregroundStyle(.manta.white)
    .background(.manta.deepGray)
    .font(.caption2)
  }
}

extension WebtoonDetailRow {
  struct ViewState {
    var thumbnail: URL?
    var title: String
    var releaseDate: Date
  }
}

private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "MMM dd, YYYY"
  
  return formatter
}()

extension View {
  func redactedShimmering(_ isActive: Bool) -> some View {
    redacted(reason: isActive ? .placeholder : [])
      .shimmering(active: isActive)
  }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
  WebtoonDetailRow(
    episode: .init(
      title: "S1 Episode 4",
      thumbnail: URL(string: "https://github.com/GangWoon/manta/assets/48466830/f849ddcd-bff5-4a11-94b0-141a6f6ee220"),
      releaseDate: Date(),
      accessType: "Unlimited"
    )
  )
}
#endif
