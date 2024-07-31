import SharedModels
import SwiftUI

struct CreatorsInfoView: View {
  let creators: Webtoon.Creators
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Creators")
        .font(.subheadline).bold()
      
      LazyVGrid(
        columns: [.init(.flexible()), .init(.flexible())],
        alignment: .leading,
        spacing: 6
      ) {
        ForEach(creators.details, id: \.0) { key, value in
          Text(key)
            .foregroundStyle(.manta.stealGray)
          
          Text(value)
        }
        .font(.footnote)
      }
    }
    .foregroundStyle(.manta.white)
    .background { Color.manta.deepGray}
  }
}

private extension String {
  var convertCamelCaseToSpaces: String? {
    let regex = try? NSRegularExpression(pattern: "([a-z])([A-Z])", options: [])
    let range = NSRange(location: 0, length: self.count)
    return regex?
      .stringByReplacingMatches(
        in: self,
        range: range,
        withTemplate: "$1 $2"
      )
  }
}

extension Webtoon.Creators {
  fileprivate var details: [(String, String)] {
    Mirror(reflecting: self).children
      .compactMap { label, value -> (String, String)? in
        guard
          let label,
          let capitalizedLabel = label.convertCamelCaseToSpaces?.capitalized,
          let value = value as? String
        else { return nil }
        return (capitalizedLabel, value)
      }
  }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
  CreatorsInfoView(
    creators: .init(
      production: "Team LYCHEE",
      illustration: "Lee Mi Nu",
      writer: "Lee Mi Nu",
      originalStory: "Lee Mi Nu",
      localization: "Manta Comics"
    )
  )
}
#endif
