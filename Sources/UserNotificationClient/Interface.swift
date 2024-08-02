import ComposableArchitecture
@preconcurrency import UserNotifications

@DependencyClient
public struct UserNotificationClient: Sendable {
  public var add: @Sendable (_ request: UNNotificationRequest) async throws -> Void
  public var remove: @Sendable (_ id: String) -> Void
  public var delegate: @Sendable () -> AsyncStream<DelegateEvent> = { .finished }
  public var getNotificationSettings: @Sendable () async -> Notification.Settings = {.init(authorizationStatus: .notDetermined) }
  public var requestAuthorization: @Sendable (_ options: UNAuthorizationOptions) async throws -> Bool
  
  @CasePathable
  public enum DelegateEvent: Sendable {
    case didReceiveResponse(Notification.Response, completionHandler: @Sendable () -> Void)
    case willPresentNotification(Notification, completionHandler: @Sendable (UNNotificationPresentationOptions) -> Void)
  }
  
  public struct Notification: Equatable, Sendable {
    public var date: Date
    public var request: UNNotificationRequest
    
    public init(
      date: Date,
      request: UNNotificationRequest
    ) {
      self.date = date
      self.request = request
    }
    
    public struct Response: Equatable, Sendable {
      public var notification: Notification
      
      public init(notification: Notification) {
        self.notification = notification
      }
    }
    
    public struct Settings: Equatable {
      public var authorizationStatus: UNAuthorizationStatus

      public init(authorizationStatus: UNAuthorizationStatus) {
        self.authorizationStatus = authorizationStatus
      }
    }
  }
}
