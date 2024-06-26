import ComposableArchitecture
import Foundation
import ApiClient

@Reducer
public struct NewAndNowCore {
  @ObservableState
  public struct State: Equatable {
    public var comingSoonList: [Components.Schemas.NewAndNow.WebToon]
    public var newArrivalsList: [Components.Schemas.NewAndNow.WebToon]
    
    public init(
      comingSoonList: [Components.Schemas.NewAndNow.WebToon] = [],
      newArrivalsList: [Components.Schemas.NewAndNow.WebToon] = []
    ) {
      self.comingSoonList = comingSoonList
      self.newArrivalsList = newArrivalsList
    }
  }
  
  public enum Action: Equatable {
    case prepare
    case fetchResponse(Components.Schemas.NewAndNow)
  }
  
  @Dependency(\.apiClient) var apiClient
  
  public init() { }
  
  public var body: some ReducerOf<Self> {
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
            print(error)
          }
        }
      
      case .fetchResponse(let data):
        state.comingSoonList = data.comingSoon
        state.newArrivalsList = data.newArrivals
        return .none
      }
    }
  }
}
