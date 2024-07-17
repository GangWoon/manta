import ComposableArchitecture
import SharedModels
import SwiftUI

@Reducer
public struct EpisodesCore {
  @ObservableState
  public struct State: Equatable, Sendable {
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
    var episodes: [Webtoon.Episode]
  }
  
  public enum Action: Equatable, Sendable, BindableAction {
    case episodeTapped(UUID)
    case binding(BindingAction<State>)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .episodeTapped:
        return .none
      case .binding:
        return .none
      }
    }
  }
}

struct EpisodesView: View {
  let store: StoreOf<EpisodesCore>
  
  var body: some View {
    WithPerceptionTracking {
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

