import ComposableArchitecture
import WebtoonDetailFeature
import LocalDatabaseClient
import UserNotificationClient
import UserNotifications
import SharedModels
import Foundation
import ApiClient

@Reducer
public struct NewAndNowCore: Sendable {
  @ObservableState
  public struct State: Equatable, Sendable {
    /// 복잡한 스크롤 뷰 로직은 뷰에서만 처리하려고 설계했지만, 스크롤 뷰 해더를 강제적으로 노출시키기 위해서 만든 값입니다.
    public var forceShowingHeader: Bool = false
    
    public var webtoons: IdentifiedArrayOf<Webtoon> = []
    public var webtoonRows: IdentifiedArrayOf<WebtoonCore.State> = []
    public var selectedWebtoonRow: WebtoonDetail.State?
    public var selectedReleaseStatus: ReleaseStatus = .comingSoon
    public let releaseCategories: [ReleaseStatus] = ReleaseStatus.allCases
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
    @Presents public var alert: AlertState<Action.Alert>?
    
    public init(
      forceShowingHeader: Bool = false,
      webtoons: IdentifiedArrayOf<Webtoon> = [],
      webtoonRows: IdentifiedArrayOf<WebtoonCore.State> = [],
      selectedWebtoonRow: WebtoonDetail.State? = nil,
      selectedReleaseStatus: ReleaseStatus = .comingSoon,
      notificationItemScrollID: NotificationItem.ID? = nil,
      notificationItems: [NotificationItem] = [],
      alert: AlertState<Action.Alert>? = nil
    ) {
      self.forceShowingHeader = forceShowingHeader
      self.webtoons = webtoons
      self.webtoonRows = webtoonRows
      self.selectedWebtoonRow = selectedWebtoonRow
      self.selectedReleaseStatus = selectedReleaseStatus
      self.notificationItemScrollID = notificationItemScrollID
      self.notificationItems = notificationItems
      self.alert = alert
    }
  }
  
  public enum Action: Equatable, Sendable, BindableAction {
    case prepare
    case webtoonResponse(Components.Schemas.NewAndNow)
    case updateWebtoonRows([UUID])
    case notificationItemTapped(State.NotificationItem.ID)
    case webtoonRows(IdentifiedActionOf<WebtoonCore>)
    case webtoonDetail(WebtoonDetail.Action)
    case updateAlertState(_ message: String, _ hasAction: Bool)
    case alert(PresentationAction<Alert>)
    case binding(BindingAction<State>)
    
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case reRequest
    }
  }
  
  @Dependency(\.database) private var database
  @Dependency(\.userNotifications) private var userNotifications
  @Dependency(\.apiClient) private var apiClient
  
  public init() { }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce<State, Action> { state, action in
      switch action {
      case .prepare:
        return fetchWebtoons()
        
      case .webtoonResponse(let data):
        let webtoons = data.webtoons
        state.webtoons.append(contentsOf: webtoons)
        return .run { send in
          let ids = try await database.fetchNotifiedWebtoons()
          await send(.updateWebtoonRows(ids))
        } catch: { error, send in
          debugPrint(error)
          await send(.updateAlertState("데이터를 불러오는데 실패했습니다.", false))
        }
        
      case .updateWebtoonRows(let ids):
        let webtoonRows = state.webtoons
          .map { $0.webtoonRow(ids.contains($0.id)) }
        state.webtoonRows.append(contentsOf: webtoonRows)
        
        state.notificationItems = webtoonRows
          .filter(\.isNotified)
          .compactMap(\.notificationItem)
        return .none
        
      case .notificationItemTapped:
        return .none
        
      case .webtoonRows(.element(id: let id, action: let action)):
        return webtoonRows(state: &state, id: id, action: action)
        
      case .webtoonDetail(let action):
        guard case .dismiss = action else { return .none }
        state.selectedWebtoonRow = nil
        return .none
        
      case .updateAlertState(let description, let hasAction):
        let action: ButtonState<Action.Alert>
        if hasAction {
          action = .init(role: .cancel, action: .reRequest) {
            TextState(description)
          }
        } else {
          action = .init(role: .cancel) {
            TextState(description)
          }
        }
        state.alert = AlertState(
          title: { TextState("알림") },
          actions: { action },
          message: {
            TextState(description)
          }
        )
        return .none
        
      case .alert(.presented(.reRequest)):
        return fetchWebtoons()
        
      case .webtoonRows, .alert, .binding:
        return .none
      }
    }
    .forEach(\.webtoonRows, action: \.webtoonRows) {
      WebtoonCore()
    }
    .ifLet(\.selectedWebtoonRow, action: \.webtoonDetail) {
      WebtoonDetail()
    }
    .ifLet(\.$alert, action: \.alert)
  }
  
  private func fetchWebtoons() -> Effect<Action> {
    .run { send in
      let response = try await apiClient.fetchNewAndNow()
      switch response {
      case .ok(let ok):
        await send(.webtoonResponse(ok.body.json))
      case .undocumented(statusCode: let code):
        await send(.updateAlertState("에러 코드: \(code)\n재요청을 시도하겠습니다.", true))
      }
    } catch: { error, send in
      debugPrint(error)
      await send(.updateAlertState("서버로 부터 데이터를 받는데 실패했습니다.\n재요청을 시도하겠습니다.", true))
    }
  }
  
  private func webtoonRows(
    state: inout State,
    id: WebtoonCore.State.ID,
    action: WebtoonCore.Action
  ) -> Effect<Action> {
    guard
      let webtoonRow = state.webtoonRows[id: id]
    else { return .none }
    switch action {
    case .tapped:
      state.selectedWebtoonRow = state.webtoons[id: id]?
        .webtoonDetail(isNotified: webtoonRow.isNotified)
      return .none
      
    case .binding(\.isNotified):
      guard
        webtoonRow.releaseStatus == .comingSoon
      else { return .none }
      state.forceShowingHeader = true
      if webtoonRow.isNotified,
         let item = webtoonRow.notificationItem {
        state.notificationItems.insertSorted(item)
      } else if let index = state.notificationItems.firstIndex(where: { $0.id == id }) {
        state.notificationItems.remove(at: index)
      }
      return .merge(
        .run { send in
          /// ScrollView가 정상적으로 동작하지 않아서 강제로 딜레이를 주고 scrollID가 설정되도록 구현했습니다.
          try await Task.sleep(for: .seconds((0.1)))
          await send(.binding(.set(\.notificationItemScrollID, webtoonRow.isNotified ? id : nil)))
        },
        .run { _ in
          try await webtoonRow.isNotified
          ? database.saveNotifiedWebtoon(id)
          : database.deleteNotifiedWebtoon(id)
        } catch: { error, send in
          debugPrint(error)
          await send(.updateAlertState("데이터를 저장하는데 실패했습니다.\n잠시후 다시 시도해주세요.", false))
        },
        .run { _ in
          if webtoonRow.isNotified {
            if let releaseDate = webtoonRow.releaseDate, releaseDate.daysDifference == 0 {
              let content = UNMutableNotificationContent()
              content.title = webtoonRow.title
              content.body = "Read Now Availbable!!"
              let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 5,
                repeats: false
              )
              let request = UNNotificationRequest(
                identifier: webtoonRow.id.uuidString,
                content: content,
                trigger: trigger
              )
              try await userNotifications.add(request)
            }
          } else {
            userNotifications.remove(id: webtoonRow.id.uuidString)
          }
        } catch: { error, _ in
          debugPrint(error)
        }
      )
      
    default:
      return .none
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
  func webtoonRow(_ isNotified: Bool) -> WebtoonCore.State {
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
      ),
      isNotified: isNotified
    )
  }
  
  func webtoonDetail(isNotified: Bool) -> WebtoonDetail.State {
    .init(
      releaseDate: releaseDate,
      title: title,
      thumbnail: thumbnail,
      ageRating: ageRating,
      tags: tags,
      summary: summary,
      episodes: episodes,
      creators: creators,
      isNotified: isNotified
    )
  }
}

extension WebtoonCore.State {
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
