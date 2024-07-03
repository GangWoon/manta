import ComposableArchitecture
import Foundation
import ApiClient

@Reducer
public struct NewAndNowCore {
  @ObservableState
  public struct State: Equatable, Sendable {
    public var selectedReleaseStatus: WebToonCore.State.ReleaseStatus
    public var scrollCategoryList: [WebToonCore.State.ReleaseStatus]
    public var webToonList: IdentifiedArrayOf<WebToonCore.State>
    
    public init(
      selectedReleaseStatus: WebToonCore.State.ReleaseStatus = .comingSoon,
      scrollCategoryList: [WebToonCore.State.ReleaseStatus] = WebToonCore.State.ReleaseStatus.allCases,
      webToonList: IdentifiedArrayOf<WebToonCore.State> = []
    ) {
      self.selectedReleaseStatus = selectedReleaseStatus
      self.scrollCategoryList = scrollCategoryList
      self.webToonList = webToonList
    }
    
    func scrollID(for releaseStatus: WebToonCore.State.ReleaseStatus) -> WebToonCore.State.ID? {
      webToonList
        .filter { $0.releaseStatus == releaseStatus }
        .first?.id
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
          } catch { }
        }
        
      case .fetchResponse(let data):
        let comingSoon = data.comingSoon
          .map { $0.webToonState(uuid(), releaseStatus: .comingSoon) }
        let newArrivals = data.newArrivals
          .map { $0.webToonState(uuid(), releaseStatus: .newArrivals) }
        state.webToonList.append(contentsOf: comingSoon + newArrivals)
        return .none
        
      case .webToonList(.element(id: let id, action: let action)):
        if 
          case .onAppear = action,
          let selectedReleaseStatus = state.webToonList[id: id]?.releaseStatus,
          state.selectedReleaseStatus != selectedReleaseStatus
        {
          state.selectedReleaseStatus = selectedReleaseStatus
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

private extension Components.Schemas.NewAndNow.WebToon {
  func webToonState(_ id: UUID, releaseStatus: WebToonCore.State.ReleaseStatus) -> WebToonCore.State {
    .init(
      id: id,
      releaseStatus: releaseStatus,
      title: title,
      tags: tags,
      thumbnailURL: thumbnail,
      thumbnailColor: thumbnailColor,
      summary: summary,
      episodes: []
    )
  }
}
