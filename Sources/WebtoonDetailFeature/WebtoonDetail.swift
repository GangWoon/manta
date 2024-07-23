import ComposableArchitecture
import SharedModels
import ViewHelper
import SwiftUI

@Reducer
public struct WebtoonDetail {
  @ObservableState
  public struct State: Equatable {
    public let buttons: [ButtonType] = ButtonType.allCases
    public enum ButtonType: Equatable, Sendable, CaseIterable {
      case save
      case notification
      case rate
      case download
      case highlights
    }
    public var releaseDate: Date?
    public var title: String
    public var thumbnail: URL?
    public var ageRating: String
    public var tags: [String]
    public var episodes: [Webtoon.Episode]
    
    public var displayedTag: String {
      guard tags.count >= 2 else { return "" }
      return tags.prefix(2).joined(separator: " · ")
    }
    
    public init(
      releaseDate: Date?,
      title: String,
      thumbnail: URL?,
      ageRating: String,
      tags: [String],
      episodes: [Webtoon.Episode]
    ) {
      self.releaseDate = releaseDate
      self.title = title
      self.thumbnail = thumbnail
      self.ageRating = ageRating
      self.tags = tags
      self.episodes = episodes
    }
  }
  
  public enum Action: Equatable, Sendable {
    case dismiss
  }
  
  public init() {
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
        .none
    }
  }
}

public struct WebtoonDetailView: View {
  @State private var naviagtionBarOpacity: CGFloat = .zero
  @State private var sectionHeaderOffset: CGFloat = .zero
  @State private var sectionHeaderHeight: CGFloat = .zero
  
  let store: StoreOf<WebtoonDetail>
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
                webtoonInfoView(proxy)
                  .padding(.horizontal)
              }
            Section {
              ForEach(0..<100) { i in
                Text("item \(i)")
                  .frame(maxWidth: .infinity)
                  .frame(height: 100)
                  .padding()
                  .background { Color.indigo }
              }
            } header: {
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
      Button(action: { store.send(.dismiss) }) {
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
  }
  
  private func webtoonInfoView(_ proxy: GeometryProxy) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text(store.ageRating)
          .font(.caption).bold()
          .foregroundStyle(.manta.white)
          .padding(.vertical, 2)
          .padding(.horizontal, 2)
          .background {
            RoundedRectangle(cornerRadius: 4)
              .fill(.gray)
          }
        
        Text(store.displayedTag)
          .font(.caption)
          .foregroundStyle(.manta.lightGray)
      }
      
      Text(store.title)
        .font(.title)
        .foregroundStyle(.manta.white)
        .padding(.bottom, 16)
      
      if let date = store.releaseDate {
        Text("Coming ")
          .foregroundStyle(.manta.lightGray)
          .font(.caption)
      }
      
      HStack(spacing: 0) {
        ForEach(store.buttons, id: \.self) { button in
          Button(action: { }) {
            VStack(spacing: 4) {
              Image(systemName: button.imageName)
                .font(.title2)
              
              Text(button.title)
                .font(.footnote)
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

private extension WebtoonDetail.State.ButtonType {
  var imageName: String {
    switch self {
    case .save:
      return "plus"
    case .notification:
      return "bell"
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
          tags: ["Romance", "Fantasy"],
          episodes: []
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
