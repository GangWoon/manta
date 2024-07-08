import ComposableArchitecture
import ViewHelper
import ApiClient
import SwiftUI

@Reducer
public struct WebToonCore {
  @ObservableState
  public struct State: Equatable, Sendable, Identifiable {
    // MARK: - ViewState
    var episodeThumbnail: URL? {
      episodes.first?.thumbnail
    }
    var arrowImage: String {
      "chevron.\(isEpisodeExpaneded ? "up": "down")"
    }
    
    public var id: UUID
    public var releaseStatus: ReleaseStatus {
      releaseDate != nil ? .comingSoon : .newArrivals
    }
    public enum ReleaseStatus: Hashable, Sendable, CaseIterable {
      case comingSoon
      case newArrivals
    }
    
    public var releaseDate: Date?
    public var title: String
    public var tags: [String]
    public var thumbnailURL: URL?
    public var thumbnailColor: String
    public var summary: String
    public var episodes: [Components.Schemas.NewAndNow.WebToon.Episode]
    
    public var isSummaryExpaneded: Bool = false
    public var isEpisodeExpaneded: Bool = false
    public var isNotified: Bool = false
  }
  
  public enum Action: Equatable, Sendable, BindableAction {
    case onAppear
    case binding(BindingAction<State>)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none
        
      case .binding:
        return .none
      }
    }
  }
}

struct WebToonRow: View {
  let store: StoreOf<WebToonCore>
  
  var body: some View {
    WithPerceptionTracking {
      VStack(spacing: 2) {
        VStack(alignment: .leading) {
          Spacer()
          
          Text(store.title)
            .font(.system(size: 22).bold())
            .foregroundStyle(.white)
          
          VStack(alignment: .leading) {
            tagList
            summaryView
            notifyButton
          }
          .padding(.bottom, 16)
        }
        .frame(height: store.episodes.isEmpty ? 500 : 600)
        .padding(.horizontal, 16)
        .background { dimmingView }
        .background { thumbnail }
        .cornerRadius(10)
        
        if !store.episodes.isEmpty {
          VStack {
            collapsed
          }
          .padding(8)
          .background {
            RoundedRectangle(cornerRadius: 9)
              .fill(Color(hex: store.thumbnailColor))
          }
        }
      }
    }
  }
  
  private var tagList: some View {
    HStack {
      ForEach(Array(store.tags.prefix(3)), id: \.self) { tag in
        Text("#\(tag)")
      }
    }
    .font(.system(size: 12))
    .foregroundStyle(store.isSummaryExpaneded ? .white : Color(hex: "#D3D3D3"))
    .onTapGesture {
      store.send(.binding(.set(\.isSummaryExpaneded, !store.isSummaryExpaneded)))
    }
  }
  
  private var summaryView: some View {
    HStack(alignment: .bottom) {
      Text(store.summary)
        .lineLimit(store.isSummaryExpaneded ? nil : 2)
        .animation(.easeInOut(duration: 0.2), value: store.isSummaryExpaneded)
        .transition(.move(edge: .bottom))
      
      if !store.isSummaryExpaneded {
        Text("More")
          .foregroundStyle(.white)
          .onTapGesture {
            store.send(.binding(.set(\.isSummaryExpaneded, true)))
          }
      }
    }
    .animation(.easeInOut, value: store.isSummaryExpaneded)
    .font(.system(size: 12))
    .foregroundStyle(store.isSummaryExpaneded ? .white : Color(hex: "#D3D3D3"))
    .onTapGesture {
      store.send(.binding(.set(\.isSummaryExpaneded, !store.isSummaryExpaneded)))
    }
  }
  
  private var dimmingView: some View {
    VStack {
      if store.isSummaryExpaneded {
        Color.black
          .opacity(0.25)
          .onTapGesture {
            store.send(.binding(.set(\.isSummaryExpaneded, !store.isSummaryExpaneded)))
          }
      }
    }
  }
  
  private var notifyButton: some View {
    Button(
      action: {
        store
          .send(
            .binding(.set(\.isNotified, !store.isNotified)),
            animation: .easeInOut
          )
      }
    ) {
      HStack {
        Image(systemName: store.isNotified ? "bell.fill" : "bell")
          .wiggleAnimation(isSelected: store.isNotified)
        
        Text(store.isNotified ? "Notification set" : "Notify me")
      }
      .font(.system(size: 16).bold())
      .foregroundStyle(.manta.white)
      .padding(.vertical, 8)
      .frame(maxWidth: .infinity)
      .background {
        RoundedRectangle(cornerRadius: 8)
          .fillAndStroke(
            fill: store.isNotified
            ? Color.clear
            : Color(hex: "#D3D3D3").opacity(0.6),
            stroke: store.isNotified
            ? Color(hex: "#D3D3D3").opacity(0.6)
            : Color.clear
          )
      }
    }
    .buttonStyle(ScaleButtonStyle())
  }
  
  private var thumbnail: some View {
    LazyImage(url: store.thumbnailURL) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fill)
        .overlay(alignment: .bottom) {
          VStack(spacing: 0) {
            LinearGradient(
              colors: [.clear, Color(hex: store.thumbnailColor)],
              startPoint: .top,
              endPoint: .bottom
            )
            .frame(height: 120)
            
            Color(hex: store.thumbnailColor)
              .frame(height: 40)
          }
        }
    } placeholder: {
      Color.clear
    }
  }
  
  private var collapsed: some View {
    HStack {
      LazyImage(url: store.episodeThumbnail) { image in
        image
          .resizable()
          .cornerRadius(6)
          .opacity(store.isEpisodeExpaneded ? 0 : 1)
          .frame(
            width: store.isEpisodeExpaneded ? 0 : 24,
            height: store.isEpisodeExpaneded ? 0 : 24
          )
      } placeholder: {
        Color.clear
      }
      
      Text(store.title)
        .font(.system(size: 14).bold())
      
      Spacer()
      
      Image(systemName: store.arrowImage)
        .font(.system(size: 11).bold())
    }
    .foregroundStyle(.white)
    .onTapGesture {
      store.send(.binding(.set(\.isEpisodeExpaneded, !store.isEpisodeExpaneded)))
    }
  }
}

//#Preview {
//  WebToonRow(
//    store: Store(
//      initialState: WebToonCore.State(
//        id: .init(),
//        title: "Choose Your Heroes Carefully",
//        tags: ["BL", "Fantasy", "Adventure"],
//        thumbnailURL: URL(string: "https://github.com/GangWoon/manta/assets/48466830/8d4487b9-a8fc-4612-9444-b5c5dc1b19c7"),
//        thumbnailColor: "#5B7AA1",
//        summary: "Stuck in a game with a lousy hero? Me too!\nMinjoon, a normal office worker, wakes up inside the game he was reviewing for his friend. It's not his fault the trailer was so boring it put him to sleep! Bewildered, Minjoon is tasked with summoning a hero to guide. The hero certainly looks strong, but he seems to be less useful than expected.",
//        episodes: [
//          .init(title: "S1 Episode 1", thumbnail: URL(string: "https://github.com/GangWoon/manta/assets/48466830/5e5081d7-d42d-4cd4-ae16-59d24f1d7456"))
//        ]
//      ),
//      reducer: WebToonCore.init
//    )
//  )
//  .frame(height: 500)
//}
