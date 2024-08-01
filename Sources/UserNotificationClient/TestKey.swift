import Dependencies

extension DependencyValues {
  public var userNotifications: UserNotificationClient {
    get { self[UserNotificationClient.self] }
    set { self[UserNotificationClient.self] = newValue }
  }
}


extension UserNotificationClient: TestDependencyKey {
  public static let previewValue: UserNotificationClient = Self.noop
  public static let testValue: UserNotificationClient = .init()
}

extension UserNotificationClient {
  public static let noop = Self(
    add: { _ in },
    remove: { _ in },
    delegate: { AsyncStream { _ in } },
    getNotificationSettings: { .init(authorizationStatus: .notDetermined) },
    requestAuthorization: { _ in false }
  )
}
