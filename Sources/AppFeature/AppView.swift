import ComposableArchitecture
import NewAndNowFeature
import SwiftUI


@Reducer
public struct AppReducer {
  @ObservableState
  public struct State: Sendable, Equatable {
    public var appDelegate: AppDelegateReducer.State
    public var newAndNow: NewAndNowCore.State
    
    public init(
      appDelegate: AppDelegateReducer.State = .init(),
      newAndNow: NewAndNowCore.State = .init()
    ) {
      self.appDelegate = appDelegate
      self.newAndNow = newAndNow
    }
  }
  
  public enum Action {
    case appDelegate(AppDelegateReducer.Action)
    case newAndNow(NewAndNowCore.Action)
  }
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.appDelegate, action: \.appDelegate) {
      AppDelegateReducer()
    }
    
    Scope(state: \.newAndNow, action: \.newAndNow) {
      NewAndNowCore()
    }
    
    Reduce<State, Action> { state, action in
      switch action {
      case .appDelegate(.userNotifications(.didReceiveResponse(_, completionHandler: let completionHandler))):
        // TODO: - Notification에서 데이터 전달 받아서 다른 작업 처리하기
        return .run { _ in
          completionHandler()
        }
      default:
        return .none
      }
    }
  }
}

public struct AppView: View {
  let store: StoreOf<AppReducer>
  
  public init(store: StoreOf<AppReducer>) {
    self.store = store
  }
  
  public var body: some View {
    WithPerceptionTracking {
      NewAndNowView(
        store: store.scope(
          state: \.newAndNow,
          action: \.newAndNow
        )
      )
    }
  }
}
