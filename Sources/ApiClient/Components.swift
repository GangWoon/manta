import Foundation

public enum Operations {
  public enum NewAndNow {
    public struct Input: Sendable {
      public init() { }
    }
    
    public enum Output: Sendable {
      public struct Ok: Sendable {
        public enum Body: Sendable {
          public var json: Components.Schemas.NewAndNow {
            get {
              switch self {
              case .json(let newAndNow):
                return newAndNow
              }
            }
          }
          case json(Components.Schemas.NewAndNow)
        }
        public var body: Body
        
        public init(body: Body) {
          self.body = body
        }
      }
      case ok(Ok)
      case undocumented(statusCode: Int)
    }
  }
}

public enum Components {
  public enum Schemas { }
}

extension Components.Schemas {
  public struct NewAndNow: Codable, Sendable {
    public struct WebToon: Codable, Sendable {
      var releaseDate: Date
      var title: String
      var thumbnail: String
      var tags: [String]
      var summary: String
      var ageRating: String
      var creators: Creators
      public struct Creators: Codable, Sendable {
        var production: String?
        var illustration: String?
        var writer: String?
        var originalStory: String?
        var localization: String?
      }
    }
    var comingSoon: [WebToon]
    var newArrivals: [WebToon]
  }
}
