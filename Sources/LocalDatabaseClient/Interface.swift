import DependenciesMacros
import Foundation

@DependencyClient
public struct LocalDatabaseClient: Sendable {
  public var fetchNotifiedWebtoons: @Sendable () async throws -> [UUID]
  public var saveNotifiedWebtoon: @Sendable (UUID) async throws -> Void
  public var deleteNotifiedWebtoon: @Sendable (UUID) async throws -> Void
}
