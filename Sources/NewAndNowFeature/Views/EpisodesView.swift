import ComposableArchitecture
import ApiClient
import SwiftUI

@Reducer
struct EpisodesCore {
  @ObservableState
  struct State: Equatable {
    // MARK: - ViewState
    var thumbnailEpisodeURL: URL? {
      episodes.first?.thumbnail
    }
    var title: String {
      isExpanded
      ? "\(episodes.count) Episodes"
      : "Binge past seasons"
    }
    
    var arrowName: String {
      "chevron." + (isExpanded ? "up" : "down")
    }
    
    var isExpanded: Bool = false
    var colorCode: String
    var episodes: [Components.Schemas.NewAndNow.WebToon.Episode]
  }
  
  enum Action: Equatable {
    case arrowToggleButtonTapped
    case episodeTapped(UUID)
  }
  
  var body: some ReducerOf<Self> {
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
    VStack {
      collapsed
        .frame(height: 24)
      
      if store.isExpanded {
        expanded
      }
    }
    .animation(.easeInOut, value: store.isExpanded)
    .padding(8)
    .background {
      RoundedRectangle(cornerRadius: 9)
        .fill(Color(hex: store.colorCode))
    }
  }
  
  private var collapsed: some View {
    HStack {
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
      
      Image(systemName: store.arrowName)
        .font(.system(size: 11).bold())
    }
    .foregroundStyle(.white)
    .onTapGesture { store.send(.arrowToggleButtonTapped) }
  }
  
  private var expanded: some View {
    ScrollView(.horizontal) {
      LazyHStack {
//        ForEach(store.episodes) { episode in
//          VStack {
//            LazyImage(url: episode.thumbnail) { image in
//              image
//                .resizable()
//                .aspectRatio(1, contentMode: .fill)
//                .cornerRadius(6)
//                .frame(height: 64)
//            } placeholder: {
//              Color.clear
//            }
//            
//            Text(episode.title)
//              .font(.system(size: 10))
//              .foregroundStyle(Color.white)
//          }
//        }
      }
    }
    .transition(.opacity)
    .frame(height: 80)
  }
}

//#Preview {
//  EpisodesView(
//    store: Store(
//      initialState: EpisodesCore.State(
//        colorCode: "#708090",
//        episodes: [
//          .init(seasonNumber: 1, episodeNumber: 1, thumbnail: ""),
//          .init(seasonNumber: 1, episodeNumber: 2, thumbnail: "https://github.com/GangWoon/manta/assets/48466830/c6739595-4236-4036-b06a-d15cabb795ce")
//        ]
//      ),
//      reducer: EpisodesCore.init
//    )
//  )
//}
//
