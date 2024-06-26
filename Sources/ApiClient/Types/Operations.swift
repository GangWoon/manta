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
