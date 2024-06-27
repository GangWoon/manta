import ComposableArchitecture
import ApiClient
import SwiftUI

@Reducer
public struct EpisodesCore {
  @ObservableState
  public struct State: Equatable {
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
    
    var isEmpty: Bool {
      episodes.isEmpty
    }
    var isExpanded: Bool = false
    var colorCode: String
    var episodes: [Components.Schemas.NewAndNow.WebToon.Episode]
  }
  
  public enum Action: Equatable, Sendable {
    case arrowToggleButtonTapped
    case episodeTapped(UUID)
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .arrowToggleButtonTapped:
        state.isExpanded.toggle()
        return .none
        
      case .episodeTapped(let id):
        return .none
      }
    }
  }
}

struct EpisodesView: View {
  let store: StoreOf<EpisodesCore>
  
  var body: some View {
    VStack(spacing: 0) {
      collapsed
        .frame(height: 24)
      
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
        .fill(Color(hex: store.colorCode))
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
        Color.clear
      }
      
      Text(store.title)
        .font(.system(size: 14).bold())
      
      Spacer()
      
      Image(systemName: store.arrowImageName)
        .font(.system(size: 11).bold())
    }
    .foregroundStyle(.white)
    .onTapGesture { store.send(.arrowToggleButtonTapped) }
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
              Color.clear
            }
            
            Text(episode.title)
              .font(.system(size: 10))
              .foregroundStyle(Color.white)
          }
        }
      }
    }
  }
}

#Preview {
  EpisodesView(
    store: Store(
      initialState: EpisodesCore.State(
        colorCode: "#708090",
        episodes: [
          .init(
            title: "S1 Episode 1",
            thumbnail: URL(string: "https://github.com/GangWoon/manta/assets/48466830/c6739595-4236-4036-b06a-d15cabb795ce")
          )
        ]
      ),
      reducer: EpisodesCore.init
    )
  )
}

