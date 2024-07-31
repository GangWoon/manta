import SharedModels
import ViewHelper
import SwiftUI

struct WebtoonInfoView: View {
  @Binding var isExpanded: Bool
  var state: State
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Summary")
        .font(.subheadline.bold())
      
      Text(state.summary)
        .foregroundStyle(.manta.stealGray)
      
      HStack {
        Text(state.ageRating)
          .badge()
        
        Text("This series is suitable for ages \(state.ageRating)")
      }
      
      ChipLayout(horizontalSpacing: 8, verticalSpacing: 8) {
        ForEach(state.visibleTags(isExpanded), id: \.self) { tag in
          Text(tag)
            .padding(3)
            .background{
              RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "#28292d"))
            }
        }
        
        if !isExpanded {
          Button(action: { isExpanded = true }) {
            Text("+ More")
              .padding(3)
              .padding(.horizontal, 4)
              .background {
                RoundedRectangle(cornerRadius: 4)
                  .stroke(Color(hex: "#28292d"), lineWidth: 2)
              }
          }
        }
      }
      .font(.caption2)
      .padding(.bottom, 32)
      
      CreatorsInfoView(creators: state.creators)
      
      Spacer()
        .frame(height: 60)
    }
    .font(.footnote)
    .foregroundStyle(.manta.white)
    .background(.manta.deepGray)
    .animation(.easeInOut, value: isExpanded)
  }
}

extension WebtoonInfoView {
  struct State {
    var summary: String
    var ageRating: String
    var tags: [String]
    var creators: Webtoon.Creators
    
    func visibleTags(_ isExpanded: Bool) -> [String] {
      isExpanded ? tags : Array(tags.prefix(5))
    }
  }
}

#if DEBUG
@available(iOS 18.0, *)
#Preview {
  @Previewable @State var isExpanded: Bool = false
  
  WebtoonInfoView(
    isExpanded: $isExpanded,
    state: .init(
      summary: "A turn of fate... by your own hand.\nAlicia Melfont vows to restore the former glory of her house after the Dark God's agent massacres her family. But when a mysterious book reveals that she's only a supporting character meant to die for the true protagonist of the story, Alicia decides she won't let some silly book determine her fate.",
      ageRating: "17+",
      tags: ["Fantasy", "Romance", "Coming of age", "Free Pass", "Fight the system", "Mythical", "Reincarnation", "Survival", "Girl crush", "Has it rough", "Knight", "Nice guy", "Soulmate", "Kingdom", "Emotional", "Inspirational", "Magical", "Exclusive"],
      creators: .init(
        production: "Team LYCHEE",
        illustration: "Lee Mi Nu",
        writer: "Lee Mi Nu",
        localization: "Manta Comics"
      )
    )
  )
}
#endif
