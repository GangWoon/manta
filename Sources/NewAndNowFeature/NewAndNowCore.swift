import ComposableArchitecture
import Foundation
import ApiClient

@Reducer
public struct NewAndNowCore {
  @ObservableState
  public struct State: Equatable, Sendable {
    public var selectedReleaseStatus: WebToonCore.State.ReleaseStatus
    public var scrollCategoryList: [WebToonCore.State.ReleaseStatus]
    
    /// 복잡한 스크롤 뷰 로직은 뷰에서만 처리하려고 설계했지만, 스크롤 뷰 해더를 강제적으로 노출시키기 위해서 만든 값입니다.
    /// 해더를 노출시키기는 로직을 리듀서 내부에서 관리하시며 안됩니다.
    public var forceShowingHeader: Bool
    
    public var notificationItemList: [NotificationItem] {
      webToonList
        .filter(\.isNotified)
        .compactMap(\.notificationItem)
    }
    public struct NotificationItem: Equatable, Sendable, Identifiable {
      public var id: WebToonCore.State.ID
      public var thumbnail: URL?
      public var releaseDate: Date
    }
    
    public var webToonList: IdentifiedArrayOf<WebToonCore.State>
    
    public init(
      selectedReleaseStatus: WebToonCore.State.ReleaseStatus = .comingSoon,
      scrollCategoryList: [WebToonCore.State.ReleaseStatus] = WebToonCore.State.ReleaseStatus.allCases,
      forceShowingHeader: Bool = false,
      webToonList: IdentifiedArrayOf<WebToonCore.State> = []
    ) {
      self.selectedReleaseStatus = selectedReleaseStatus
      self.scrollCategoryList = scrollCategoryList
      self.forceShowingHeader = forceShowingHeader
      self.webToonList = webToonList
    }
    
    func scrollID(for releaseStatus: WebToonCore.State.ReleaseStatus) -> WebToonCore.State.ID? {
      webToonList
        .filter { $0.releaseStatus == releaseStatus }
        .first?
        .id
    }
  }
  
  public enum Action: Equatable, Sendable, BindableAction {
    case prepare
    case fetchResponse(Components.Schemas.NewAndNow)
    case webToonList(IdentifiedActionOf<WebToonCore>)
    case binding(BindingAction<State>)
  }
  
  @Dependency(\.apiClient) var apiClient
  @Dependency(\.uuid) var uuid
  
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
        let comingSoon = data.comingSoon
          .map { $0.webToonState(uuid(), releaseStatus: .comingSoon) }
        let newArrivals = data.newArrivals
          .map { $0.webToonState(uuid(), releaseStatus: .newArrivals) }
        state.webToonList.append(contentsOf: comingSoon + newArrivals)
        return .none
        
      case .webToonList(.element(id: let id, action: let action)):
        guard
          let webToonState = state.webToonList[id: id]
        else { return .none }
        switch action {
        case .onAppear:
          if state.selectedReleaseStatus != webToonState.releaseStatus {
          state.selectedReleaseStatus = webToonState.releaseStatus
        }
        case .notifyButtonTapped:
          state.forceShowingHeader = true
        }
        return .none
        
      case .webToonList, .binding:
        return .none
      }
    }
    .forEach(\.webToonList, action: \.webToonList) {
      WebToonCore()
    }
  }
}

extension WebToonCore.State {
  var notificationItem: NewAndNowCore.State.NotificationItem? {
    if let releaseDate {
      return .init(
        id: id,
        thumbnail: thumbnailURL,
        releaseDate: releaseDate
      )
    }
    return nil
  }
}

private extension Components.Schemas.NewAndNow.WebToon {
  func webToonState(_ id: UUID, releaseStatus: WebToonCore.State.ReleaseStatus) -> WebToonCore.State {
    .init(
      id: id,
      releaseDate: releaseDate,
      title: title,
      tags: tags,
      thumbnailURL: thumbnail,
      thumbnailColor: thumbnailColor,
      summary: summary,
      episodes: []
    )
  }
}
