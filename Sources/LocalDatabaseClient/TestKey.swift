import Dependencies
import Foundation

extension DependencyValues {
  public var database: LocalDatabaseClient {
    get { self[LocalDatabaseClient.self] }
    set { self[LocalDatabaseClient.self] = newValue }
  }
}

extension LocalDatabaseClient: TestDependencyKey {
  static public let previewValue: LocalDatabaseClient = Self.mock
  static public let testValue: LocalDatabaseClient = .init()
}

extension LocalDatabaseClient {
  public static var mock: Self {
    return .init(
      fetchNotifiedWebtoons: { [] },
      saveNotifiedWebtoon: { _ in },
      deleteNotifiedWebtoon: { _ in }
    )
  }
}
