@preconcurrency import ComposableArchitecture
import Foundation
import ApiClient

@Reducer
public struct NewAndNowCore {
  @ObservableState
  public struct State: Equatable, Sendable {
    public var selectedCategory: ScrollCategory
    public enum ScrollCategory: Equatable, Sendable, CaseIterable {
      case comingSoon
      case newArrivals
    }
    
    public var scrollCategoryList: [ScrollCategory]
    public var webToonList: IdentifiedArrayOf<WebToonCore.State>
    
    public init(
      selectedCategory: ScrollCategory = .comingSoon,
      scrollCategoryList: [ScrollCategory] = ScrollCategory.allCases,
      webToonList: IdentifiedArrayOf<WebToonCore.State> = []
    ) {
      self.selectedCategory = selectedCategory
      self.scrollCategoryList = scrollCategoryList
      self.webToonList = webToonList
    }
  }
  
  public enum Action: Equatable, Sendable, BindableAction {
    case binding(BindingAction<State>)
    case prepare
    case fetchResponse(Components.Schemas.NewAndNow)
    case webToonList(IdentifiedActionOf<WebToonCore>)
  }
  
  @Dependency(\.apiClient) var apiClient
  @Dependency(\.uuid) var uuid
  
  public init() { }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
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
            print("!!!", error)
          }
        }
        
      case .fetchResponse(let data):
        let comingSoon = data.comingSoon
          .map { $0.webToonState(uuid(), type: .comingSoon) }
//        let newArrivals = data.newArrivals
//          .map { $0.webToonState(uuid(), type: .newArrivals) }
        state.webToonList.append(contentsOf: comingSoon)
        print(comingSoon.count)
        return .none
        
      case .webToonList:
        return .none
        
      case .binding:
        return .none
      }
    }
    .forEach(\.webToonList, action: \.webToonList) {
      WebToonCore()
    }
    
  }
}

private extension Components.Schemas.NewAndNow.WebToon {
  func webToonState(_ id: UUID, type: WebToonCore.State.ReleaseStatus) -> WebToonCore.State {
    .init(
      id: id,
      type: type,
      title: title,
      tags: tags,
      thumbnailURL: thumbnail,
      thumbnailColor: thumbnailColor,
      summary: summary,
      episodes: []
    )
  }
}
