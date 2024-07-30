import ComposableArchitecture
import SharedModels
import ViewHelper
import SwiftUI

@Reducer
public struct WebtoonDetail {
  @ObservableState
  public struct State: Equatable {
    public var buttons: [ButtonType]
    public enum ButtonType: Hashable, Sendable {
      case save
      case notification(Bool)
      case rate
      case download
      case highlights
    }
    public var releaseDate: Date?
    public var title: String
    public var thumbnail: URL?
    public var ageRating: String
    public var tags: [String]
    public var summary: String
    public var episodes: [Webtoon.Episode]
    public var creators: Webtoon.Creators
    public var isNotified: Bool
    public var isTagListExpanded: Bool
    
    var primaryTag: String {
      guard tags.count >= 2 else { return "" }
      return tags.prefix(2).joined(separator: " · ")
    }
    var visibleTagList: [String] {
      if isTagListExpanded {
        tags
      } else {
        Array(tags.prefix(5))
      }
    }
    var webtoonInfoState: WebtoonInfoView.State {
      .init(
        summary: summary,
        ageRating: ageRating,
        tags: tags,
        creators: creators
      )
    }
    
    public init(
      releaseDate: Date?,
      title: String,
      thumbnail: URL?,
      ageRating: String,
      tags: [String],
      summary: String,
      episodes: [Webtoon.Episode],
      creators: Webtoon.Creators,
      isNotified: Bool,
      isTagListExpanded: Bool = false
    ) {
      self.releaseDate = releaseDate
      self.title = title
      self.thumbnail = thumbnail
      self.ageRating = ageRating
      self.tags = tags
      self.summary = summary
      self.episodes = episodes
      self.creators = creators
      self.isNotified = isNotified
      self.isTagListExpanded = isTagListExpanded
      self.buttons = [
        .save,
        .notification(isNotified),
        .rate
      ]
      if !episodes.isEmpty {
        self.buttons.append(
          contentsOf: [
            .download,
            .highlights
          ]
        )
      }
    }
  }
  
  public enum Action: Equatable, Sendable, BindableAction {
    case dismiss
    case binding(BindingAction<State>)
  }
  
  public init() {
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
        .none
    }
  }
}

public struct WebtoonDetailView: View {
  @State private var naviagtionBarOpacity: CGFloat = .zero
  @State private var sectionHeaderOffset: CGFloat = .zero
  @State private var sectionHeaderHeight: CGFloat = .zero
  
  @Perception.Bindable var store: StoreOf<WebtoonDetail>
  let animation: Namespace.ID
  
  public init(
    store: StoreOf<WebtoonDetail>,
    animation: Namespace.ID
  ) {
    self.store = store
    self.animation = animation
  }
  
  public var body: some View {
    GeometryReader { proxy in
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
          WithPerceptionTracking {
            thumbnail(proxy)
              .overlay(alignment: .bottomLeading) {
                webtoonTitle(proxy)
                  .padding(.horizontal)
              }
            
            Section {
              if store.episodes.isEmpty {
                WebtoonInfoView(
                  isExpanded: $store.isTagListExpanded,
                  state: store.webtoonInfoState
                )
                .padding(.horizontal, 16)
              } else {
                ForEach(0..<100) { i in
                  Text("item \(i)")
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .padding()
                    .background { Color.indigo }
                }
              }
            } header: {
              if !store.episodes.isEmpty {
                WithPerceptionTracking {
                  Text("\(store.episodes.count) Episodes")
                    .font(.subheadline)
                    .foregroundStyle(.manta.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background { Color.manta.deepGray }
                    .offset(y: sectionHeaderOffset)
                    .readSize { sectionHeaderHeight = $0.height }
                }
              }
            }
          }
        }
        .readScrollOffset(axis: .vertical) { offset in
          updateSectionHeaderPosition(proxy: proxy, offset: offset)
          updateNavigationBarOpacity(offset)
        }
      }
      .background { Color.manta.deepGray }
      .overlay(alignment: .topLeading) {
        navigationBar(proxy)
      }
      .scrollIndicators(.hidden)
      .ignoresSafeArea(.all)
    }
  }
  
  private func navigationBar(_ proxy: GeometryProxy) -> some View {
    HStack {
      Button(action: { store.send(.dismiss, animation: .hero) }) {
        Image(systemName: "chevron.left")
          .foregroundStyle(.manta.white)
          .padding()
      }
      .buttonStyle(.plain)
      .contentShape(Rectangle())
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.top, proxy.safeAreaInsets.top)
    .background {
      Color.manta.deepGray
        .opacity(naviagtionBarOpacity)
        .animation(.easeInOut, value: naviagtionBarOpacity)
    }
  }
  
  private func updateNavigationBarOpacity(_ offset: CGFloat) {
    let threshold: CGFloat = 200
    if (0.0...threshold).contains(offset) {
      naviagtionBarOpacity = min(max(offset / threshold, 0.0), 1)
    } else if offset < 0, naviagtionBarOpacity != 0 {
      naviagtionBarOpacity = 0
    } else if offset > threshold, naviagtionBarOpacity != 1 {
      naviagtionBarOpacity = 1
    }
  }
  
  private func updateSectionHeaderPosition(proxy: GeometryProxy, offset: CGFloat) {
    let headerResistance = 10.0
    let baseOffset = proxy.safeAreaInsets.top + sectionHeaderHeight
    let thumbnailHeight = proxy.size.width * 0.8 + 200
    let thresholdOffset = thumbnailHeight - baseOffset + headerResistance
    if thresholdOffset < offset {
      sectionHeaderOffset = min(baseOffset - headerResistance, offset - thresholdOffset)
    } else {
      sectionHeaderOffset = 0
    }
  }
  
  private func thumbnail(_ proxy: GeometryProxy) -> some View {
    VStack(spacing: -proxy.size.width * 0.2) {
      LazyImage(url: store.thumbnail) { image in
        image
          .resizable()
          .scaledToFill()
          .frame(height: proxy.size.width, alignment: .top)
          .clipped()
      } placeholder: {
        Color.clear
      }
      .frame(height: proxy.size.width)
      
      LinearGradient(
        stops: [
          .init(color: .clear, location: 0),
          .init(color: .manta.deepGray.opacity(0.3), location: 0.1),
          .init(color: .manta.deepGray.opacity(0.9), location: 0.25),
          .init(color: .manta.deepGray, location: 0.3)
        ],
        startPoint: .top,
        endPoint: .bottom
      )
      .frame(height: 200)
    }
    .matchedGeometryEffect(id: store.thumbnail, in: animation)
  }
  
  private func webtoonTitle(_ proxy: GeometryProxy) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text(store.ageRating)
          .badge()
        
        Text(store.primaryTag)
          .font(.caption)
          .foregroundStyle(.manta.lightGray)
      }
      .matchedGeometryEffect(
        id: store.tags,
        in: animation,
        properties: .position
      )
      
      Text(store.title)
        .font(.title)
        .foregroundStyle(.manta.white)
        .padding(.bottom, 16)
        .matchedGeometryEffect(
          id: store.title,
          in: animation,
          properties: .position
        )
      
      if let date = store.releaseDate {
        Text("Coming " + dateFormatter.string(from: date))
          .foregroundStyle(.manta.lightGray)
          .font(.caption)
          .padding(.bottom, 16)
      }
      
      HStack(spacing: 0) {
        ForEach(store.buttons, id: \.self) { button in
          Button(action: { }) {
            VStack(spacing: 4) {
              Image(systemName: button.imageName)
                .font(.title3)
              
              Text(button.title)
                .font(.caption2)
            }
          }
          .frame(width: (proxy.size.width - 32) / 5)
        }
        .foregroundStyle(.manta.lightGray)
      }
      .padding(.bottom, 8)
      
      Color.manta.lightGray
        .frame(height: 1)
        .padding(.bottom, 16)
    }
  }
}

private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "EEE, MMM dd"
  
  return formatter
}()

private extension WebtoonDetail.State.ButtonType {
  var imageName: String {
    switch self {
    case .save:
      return "plus"
    case .notification(let isNotified):
      return isNotified ? "bell.fill" : "bell"
    case .rate:
      return "hand.thumbsup"
    case .download:
      return "arrow.down.to.line"
    case .highlights:
      return "photo.circle"
    }
  }
  
  var title: String {
    switch self {
    case .save:
      return "Save"
    case .notification:
      return "Notification"
    case .rate:
      return "Rate"
    case .download:
      return "Download"
    case .highlights:
      return "Highlights"
    }
  }
}

#if DEBUG
struct WebtoonDetailTest: View {
  @Namespace var animation
  
  var body: some View {
    WebtoonDetailView(
      store: Store(
        initialState: WebtoonDetail.State(
          releaseDate: .now,
          title: "The Accidental Heiress",
          thumbnail: URL(string: "https://github.com/GangWoon/manta/assets/48466830/b6cb2767-ed85-4f5b-9de4-55d64b82c62d"),
          ageRating: "17+",
          tags: ["Fantasy", "Romance", "Coming of age", "Free Pass", "Fight the system", "Mythical", "Reincarnation", "Survival", "Girl crush", "Has it rough", "Knight", "Nice guy", "Soulmate", "Kingdom", "Emotional", "Inspirational", "Magical", "Exclusive"],
          summary: "A turn of fate... by your own hand.\nAlicia Melfont vows to restore the former glory of her house after the Dark God's agent massacres her family. But when a mysterious book reveals that she's only a supporting character meant to die for the true protagonist of the story, Alicia decides she won't let some silly book determine her fate.",
          episodes: [],
          creators: .init(
            production: "Team LYCHEE",
            illustration: "Lee Mi Nu",
            writer: "Lee Mi Nu",
            localization: "Manta Comics"
          ),
          isNotified: true
        ),
        reducer: WebtoonDetail.init
      ),
      animation: animation
    )
  }
}

@available(iOS 17.0, *)
#Preview {
  WebtoonDetailTest()
}
#endif
