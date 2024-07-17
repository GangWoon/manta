import ComposableArchitecture
import WebtoonDetailFeature
import SharedModels
import Foundation
import ApiClient

@Reducer
public struct NewAndNowCore {
  @ObservableState
  public struct State: Equatable, Sendable {
    /// 복잡한 스크롤 뷰 로직은 뷰에서만 처리하려고 설계했지만, 스크롤 뷰 해더를 강제적으로 노출시키기 위해서 만든 값입니다.
    /// 해더를 노출시키기는 로직을 리듀서 내부에서 관리하시며 안됩니다.
    public var forceShowingHeader: Bool = false
    public var categoryChangeHeight: CGFloat = .zero
    var scrollThreshold: CGFloat {
      webtoonRows
        .filter { $0.releaseStatus == .comingSoon }
        .map { $0.episodes.isEmpty ? 500.0 : 600 }
        .reduce(into: 0, +=)
    }
    
    public var webtoons: [Webtoon] = []
    public var webtoonRows: IdentifiedArrayOf<WebToonCore.State> = []
    public var selectedWebtoonRow: WebtoonDetail.State?
    public var selectedReleaseStatus: ReleaseStatus = .comingSoon
    public var releaseCategories: [ReleaseStatus] = ReleaseStatus.allCases
    public enum ReleaseStatus: Hashable, Sendable, CaseIterable {
      case comingSoon
      case newArrivals
    }
    
    public var notificationItemScrollID: NotificationItem.ID?
    public var notificationItems: [NotificationItem] = []
    public struct NotificationItem: Sendable, Equatable, Identifiable {
      public var id: UUID
      public var thumbnail: URL?
      public var releaseDate: Date
    }
    
    public init() { }
  }
  
  public enum Action: Equatable, Sendable, BindableAction {
    case prepare
    case fetchResponse(Components.Schemas.NewAndNow)
    case notificationItemTapped(State.NotificationItem.ID)
    case webtoonRows(IdentifiedActionOf<WebToonCore>)
    case webtoonDetail(WebtoonDetail.Action)
    case binding(BindingAction<State>)
  }
  
  @Dependency(\.apiClient) private var apiClient
  @Dependency(\.uuid) private var uuid
  
  public init() { }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()

    Reduce<State, Action> { state, action in
      switch action {
      case .prepare:
        return .run { send in
          do {
            let response = try await apiClient.fetchNewAndNow()
            switch response {
            case .ok(let ok):
              await send(.fetchResponse(ok.body.json))
              
            case .undocumented(statusCode: let code):
              print(code)
            }
          } catch { 
            print(error)
          }
        }
        
      case .fetchResponse(let data):
        let webtoons = data.webtoons
        state.webtoons = webtoons
        state.webtoonRows.append(contentsOf: webtoons.map(\.webtoonRow))
        
        /// ViewState를 Reducer 내부로 가두는걸 선호하지 않지만,
        /// Reducer macro에서 발생하는 View에서 State변경 에러를 피하고자 추가햇습니다.
        state.categoryChangeHeight = state.scrollThreshold
        return .none
        
      case .notificationItemTapped(let id):
        return .none
        
      case .webtoonRows(.element(id: let id, action: let action)):
        guard
          let webToonState = state.webtoonRows[id: id]
        else { return .none }
        switch action {
        case .tapped:
          return .none
          
        case .binding(\.isNotified):
          state.forceShowingHeader = true
          if webToonState.isNotified {
            if let item = webToonState.notificationItem {
              state.notificationItems.insertSorted(item)
            }
          } else {
            if let index = state.notificationItems.firstIndex(where: { $0.id == id }) {
              state.notificationItems.remove(at: index)
            }
          }
          return .run { send in
            /// ScrollView가 정상적으로 동작하지 않아서 강제로 딜레이를 주고 scrollID가 설정되도록 구현했습니다.
            try await Task.sleep(for: .seconds((0.1)))
            await send(.binding(.set(\.notificationItemScrollID, webToonState.isNotified ? id : nil)))
          }
          
        default:
          return .none
        }
        
      case .webtoonRows,
          .binding:
        return .none
      }
    }
    .forEach(\.webtoonRows, action: \.webtoonRows) {
      WebToonCore()
    }
    .ifLet(\.selectedWebtoonRow, action: \.webtoonDetail) {
      WebtoonDetail()
    }
  }
}

// MARK: - Components
private extension Components.Schemas.NewAndNow {
  var webtoons: [Webtoon] {
    comingSoon + newArrivals
  }
}

private extension Webtoon {
  var webtoonRow: WebToonCore.State {
    .init(
      id: id,
      releaseDate: releaseDate,
      title: title,
      tags: tags,
      thumbnailURL: thumbnail,
      thumbnailSmallURL: thumbnailSmall,
      thumbnailColor: thumbnailColor,
      summary: summary,
      isNewSeason: isNewSeason,
      episodes: .init(
        colorCode: thumbnailColor,
        episodes: episodes
      )
    )
  }
}

extension WebToonCore.State {
  var notificationItem: NewAndNowCore.State.NotificationItem? {
    if let releaseDate {
      return .init(
        id: id,
        thumbnail: thumbnailSmallURL,
        releaseDate: releaseDate
      )
    }
    return nil
  }
  
  var releaseStatus: NewAndNowCore.State.ReleaseStatus {
    releaseDate != nil ? .comingSoon : .newArrivals
  }
}

extension Array where Element: Comparable {
  mutating func insertSorted(_ element: Element) {
    if let index = self.firstIndex(where: { $0 > element }) {
      self.insert(element, at: index)
    } else {
      self.append(element)
    }
  }
}
