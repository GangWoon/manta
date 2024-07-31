import ComposableArchitecture
import SharedModels
import ViewHelper
import SwiftUI

@Reducer
public struct EpisodesCore {
  @ObservableState
  public struct State: Equatable, Sendable {
    var isEmpty: Bool {
      episodes.isEmpty
    }
    var colorCode: String
    var episodes: [Webtoon.Episode]
    
    // MARK: - ViewState
    fileprivate var thumbnailEpisodeURL: URL? {
      episodes.first?.thumbnail
    }
    fileprivate var title: String {
      isExpanded
      ? "\(episodes.count) Episodes"
      : "Binge past seasons"
    }
    fileprivate var arrowImageName: String {
      "chevron.\(isExpanded ? "up": "down")"
    }
    var isExpanded: Bool = false
  }
  
  public enum Action: Equatable, Sendable, BindableAction {
    case episodeTapped(UUID)
    case binding(BindingAction<State>)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
        .none
    }
  }
}

struct EpisodesView: View {
  let store: StoreOf<EpisodesCore>
  var isShimmering: Bool
  
  var body: some View {
    WithPerceptionTracking {
      VStack(spacing: 0) {
        collapsed
          .frame(height: 24)
          .redactedShimmering(isShimmering)
        
        expanded
          .transition(.opacity)
          .frame(height: store.isExpanded ? 80 : 0)
          .opacity(store.isExpanded ? 1 : 0)
      }
      .animation(.easeInOut, value: store.isExpanded)
      .transition(.opacity)
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background {
        RoundedRectangle(cornerRadius: 9)
          .fill(
            isShimmering
            ? Color.manta.slateGray
            : Color(hex: store.colorCode)
          )
      }
    }
  }
  
  private var collapsed: some View {
    HStack(spacing: store.isExpanded ? 0 : 4) {
      LazyImage(url: store.thumbnailEpisodeURL) { image in
        image
          .resizable()
          .cornerRadius(6)
          .opacity(store.isExpanded ? 0 : 1)
          .frame(
            width: store.isExpanded ? 0 : 24,
            height: store.isExpanded ? 0 : 24
          )
      } placeholder: {
        Color.manta.slateGray
          .frame(width: 24, height: 24)
          .shimmering()
      }
      
      Text(store.title)
        .font(.subheadline.bold())
      
      Spacer()
      
      Image(systemName: store.arrowImageName)
        .font(.caption.bold())
    }
    .foregroundStyle(.manta.white)
    .onTapGesture {
      store.send(.binding(.set(\.isExpanded, !store.isExpanded)))
    }
  }
  
  private var expanded: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack {
        ForEach(store.episodes) { episode in
          VStack {
            LazyImage(url: episode.thumbnail) { image in
              image
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .cornerRadius(6)
                .frame(height: 64)
            } placeholder: {
              Color.manta.slateGray
                .shimmering()
            }
            
            Text(episode.title)
              .font(.caption2)
              .foregroundStyle(Color.manta.white)
          }
        }
      }
    }
  }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
  EpisodesView(
    store: Store(
      initialState: EpisodesCore.State(
        colorCode: "#708090",
        episodes: [
          .init(
            title: "S1 Episode 1",
            thumbnail: URL(string: "https://github.com/GangWoon/manta/assets/48466830/c6739595-4236-4036-b06a-d15cabb795ce"),
            releaseDate: .now,
            accessType: "Free"
          )
        ]
      ),
      reducer: EpisodesCore.init
    ),
    isShimmering: true
  )
}
#endif
