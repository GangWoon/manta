import ComposableArchitecture
import UserNotificationClient
import Foundation

@Reducer
public struct AppDelegateReducer {
  public struct State: Equatable {
    public init() {}
  }
  
  public enum Action {
    case didFinishLaunching
    case userNotifications(UserNotificationClient.DelegateEvent)
  }
  
  @Dependency(\.userNotifications) private var userNotifications
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .didFinishLaunching:
        let userNotificationsEventStream = userNotifications.delegate()
        return .run { send in
          await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
              for await event in userNotificationsEventStream {
                await send(.userNotifications(event))
              }
            }
            
            group.addTask {
              let settings = await userNotifications.getNotificationSettings()
              switch settings.authorizationStatus {
              case .notDetermined, .authorized:
                guard
                  try await userNotifications.requestAuthorization([.alert, .sound, .sound])
                else { return }
              case . provisional:
                guard
                  try await userNotifications.requestAuthorization(.provisional)
                else { return }
              default:
                return
              }
            }
          }
        }
        
      case .userNotifications(.willPresentNotification(_, completionHandler: let completion)):
        completion(.banner)
        return .none
      
      case .userNotifications:
        return .none
      }
    }
  }
}
