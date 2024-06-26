import DependenciesMacros
import Foundation

@DependencyClient
public struct ApiClient: Sendable {
  public var fetchNewAndNow: @Sendable () async throws -> Operations.NewAndNow.Output
}
