import Dependencies

extension ApiClient: DependencyKey {
  public static let liveValue: ApiClient = Self.mock
}
