import UserNotifications
import Dependencies

// MARK: - Swift 6.0
//extension UserNotificationClient: @preconcurrency DependencyKey {
extension UserNotificationClient: DependencyKey {
  @MainActor
  public static var liveValue: UserNotificationClient = {
    return .init(
      add: { try await UNUserNotificationCenter.current().add($0) },
      remove: { UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [$0]) },
      delegate: {
        .init { continuation in
          let delegate = Delegate(continuation: continuation)
          UNUserNotificationCenter.current().delegate = delegate
          continuation.onTermination = { _ in
            _ = delegate
          }
        }
      },
      getNotificationSettings: { await .init(rawValue: UNUserNotificationCenter.current().notificationSettings()) },
      requestAuthorization: { try await UNUserNotificationCenter.current().requestAuthorization(options: $0) }
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
  fileprivate final class Delegate: NSObject, UNUserNotificationCenterDelegate, Sendable {
    let continuation: AsyncStream<UserNotificationClient.DelegateEvent>.Continuation
    
    init(continuation: AsyncStream<UserNotificationClient.DelegateEvent>.Continuation) {
      self.continuation = continuation
    }
    
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      didReceive response: UNNotificationResponse
    ) async {
      await withCheckedContinuation { continuation in
        self.continuation.yield(
          .didReceiveResponse(.init(rawValue: response)) {
            continuation.resume()
          }
        )
      }
    }
    
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
      await withCheckedContinuation { continutaion in
        self.continuation.yield(
          .willPresentNotification(.init(rawValue: notification)) {
            continutaion.resume(returning: $0)
          }
        )
      }
    }
  }
}
