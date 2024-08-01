import UserNotifications
import Dependencies

extension UserNotificationClient: DependencyKey {
  public static var liveValue: UserNotificationClient = {
    let center = UNUserNotificationCenter.current()
    return .init(
      add: { try await center.add($0) },
      remove: { center.removePendingNotificationRequests(withIdentifiers: [$0]) },
      delegate: {
        .init { continuation in
          let delegate = Delegate(continuation: continuation)
          center.delegate = delegate
          continuation.onTermination = { _ in
            _ = delegate
          }
        }
      },
      getNotificationSettings: { await .init(rawValue: center.notificationSettings()) },
      requestAuthorization: { try await center.requestAuthorization(options: $0) }
    )
  }()
}

extension UserNotificationClient.Notification {
  public init(rawValue: UNNotification) {
    self.date = rawValue.date
    self.request = rawValue.request
  }
}

extension UserNotificationClient.Notification.Response {
  public init(rawValue: UNNotificationResponse) {
    self.notification = .init(rawValue: rawValue.notification)
  }
}

extension UserNotificationClient.Notification.Settings {
  public init(rawValue: UNNotificationSettings) {
    self.authorizationStatus = rawValue.authorizationStatus
  }
}

extension UserNotificationClient {
  fileprivate final class Delegate: NSObject, UNUserNotificationCenterDelegate {
    let continuation: AsyncStream<UserNotificationClient.DelegateEvent>.Continuation
    
    init(continuation: AsyncStream<UserNotificationClient.DelegateEvent>.Continuation) {
      self.continuation = continuation
    }
    
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      didReceive response: UNNotificationResponse,
      withCompletionHandler completionHandler: @escaping () -> Void
    ) {
      continuation.yield(
        .didReceiveResponse(.init(rawValue: response)) { completionHandler() }
      )
    }
    
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
      continuation.yield(
        .willPresentNotification(.init(rawValue: notification)) { completionHandler($0) }
      )
    }
  }
}
