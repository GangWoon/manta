import SharedModels
import Foundation

public enum Components {
  public enum Schemas { }
}

extension Components.Schemas {
  public struct NewAndNow: Codable, Sendable, Equatable {
    public var comingSoon: [Webtoon]
    public var newArrivals: [Webtoon]
  }
}
