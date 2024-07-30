import ComposableArchitecture
import ViewHelper
import ApiClient
import SwiftUI
import Shimmer

@Reducer
public struct WebToonCore {
  @ObservableState
  public struct State: Equatable, Sendable, Identifiable {
    var releaseStatus: NewAndNowCore.State.ReleaseStatus {
      releaseDate != nil ? .comingSoon : .newArrivals
    }
    
    public var id: UUID
    public var releaseDate: Date?
    public var title: String
    public var tags: [String]
    public var thumbnailURL: URL?
    public var thumbnailSmallURL: URL?
    public var thumbnailColor: String
    public var summary: String
    public var isNewSeason: Bool?
    public var episodes: EpisodesCore.State
    
    public var isSummaryExpaneded: Bool = false
    public var isNotified: Bool = false
  }
  
  public enum Action: Equatable, Sendable, BindableAction {
    case tapped
    case episodes(EpisodesCore.Action)
    case binding(BindingAction<State>)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Scope(state: \.episodes, action: \.episodes) {
      EpisodesCore()
    }
    
    Reduce { state, action in
        .none
    }
  }
}

struct WebToonRow: View {
  let store: StoreOf<WebToonCore>
  
  var animation: Namespace.ID
  
  var body: some View {
    WithPerceptionTracking {
      VStack(spacing: 2) {
        VStack(alignment: .leading) {
          Spacer()
            .frame(height: 16)
          
          if let date = store.releaseDate {
            releaseDate(date)
          } else {
            eqisodeTag
          }
          
          Spacer()
          
          Text(store.title)
            .font(.system(size: 22).bold())
            .foregroundStyle(.white)
            .matchedGeometryEffect(
              id: store.title,
              in: animation,
              properties: .position
            )
          
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
        .onTapGesture { store.send(.tapped, animation: .hero) }
        
        if !store.episodes.isEmpty {
          EpisodesView(
            store: store
              .scope(state: \.episodes, action: \.episodes)
          )
        }
      }
    }
  }
  
  private func releaseDate(_ date: Date) -> some View {
    VStack(spacing: 0) {
      Text(dayFormatter.string(from: date))
        .font(.system(size: 24).bold())
        .foregroundStyle(.manta.white)
      
      Text(monthFormatter.string(from: date))
        .font(.system(size: 10).bold())
        .foregroundStyle(.manta.gray)
    }
    .frame(width: 45, height: 52)
    .background {
      RoundedRectangle(cornerRadius: 8)
        .fill(.manta.blackA05)
    }
  }
  
  private var eqisodeTag: some View {
    Text(
      store.isNewSeason ?? false
      ? "NEW SEASON"
      : "NEW"
    )
    .font(.system(size: 14).bold())
    .foregroundStyle(.manta.white)
    .padding(.vertical, 2)
    .padding(.horizontal, 4)
    .background {
      RoundedRectangle(cornerRadius: 4)
        .fill(Color.red)
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
    .matchedGeometryEffect(
      id: store.tags,
      in: animation,
      properties: .position
    )
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
    Group {
      if store.releaseStatus == .comingSoon {
        Button(
          action: {
            let bindingAction = WebToonCore.Action
              .binding(.set(\.isNotified, !store.isNotified))
            store.send(bindingAction, animation: .easeInOut)
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
      } else {
        Button(
          action: { store.send(.tapped, animation: .hero) }
        ) {
          Text("Check it out")
            .font(.system(size: 16).bold())
            .foregroundStyle(.manta.white)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background {
              RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#D3D3D3").opacity(0.6))
            }
        }
        .buttonStyle(ScaleButtonStyle())
      }
    }
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
      Color(hex: store.thumbnailColor)
        .shimmering(bandSize: 0.6)
    }
    .matchedGeometryEffect(id: store.thumbnailURL, in: animation)
  }
}

private let dayFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "d"
  return formatter
}()

private let monthFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "MMM"
  return formatter
}()

#if DEBUG
struct WebtoonRowPreview: View {
  @Namespace var animation
  var body: some View {
    WebToonRow(
      store: Store(
        initialState: WebToonCore.State(
          id: .init(),
          title: "Choose Your Heroes Carefully",
          tags: ["BL", "Fantasy", "Adventure"],
          thumbnailURL: URL(string: "https://github.com/GangWoon/manta/assets/48466830/8d4487b9-a8fc-4612-9444-b5c5dc1b19c7"),
          thumbnailColor: "#5B7AA1",
          summary: "Stuck in a game with a lousy hero? Me too!\nMinjoon, a normal office worker, wakes up inside the game he was reviewing for his friend. It's not his fault the trailer was so boring it put him to sleep! Bewildered, Minjoon is tasked with summoning a hero to guide. The hero certainly looks strong, but he seems to be less useful than expected.",
          isNewSeason: true,
          episodes: .init(
            colorCode: "#5B7AA1",
            episodes: [
              .init(
                title: "S1 Episode 1",
                thumbnail: URL(string: "https://github.com/GangWoon/manta/assets/48466830/5e5081d7-d42d-4cd4-ae16-59d24f1d7456"),
                releaseDate: .now,
                accessType: "Free"
              )
            ]
          )
        ),
        reducer: WebToonCore.init
      ),
      animation: animation
    )
  }
}
#Preview {
  WebtoonRowPreview()
    .frame(height: 500)
}
#endif
