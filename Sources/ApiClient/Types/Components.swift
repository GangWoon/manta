import Foundation

public enum Components {
  public enum Schemas { }
}

extension Components.Schemas {
  public struct NewAndNow: Codable, Sendable, Equatable {
    public struct WebToon: Codable, Sendable, Equatable, Identifiable {
      public var id: UUID
      public var releaseDate: Date
      public var title: String
      public var thumbnail: String
      public var thumbnailColor: String
      public var tags: [String]
      public var summary: String
      public var ageRating: String
      public var creators: Creators
      public struct Creators: Codable, Sendable, Equatable {
        public var production: String?
        public var illustration: String?
        public var writer: String?
        public var originalStory: String?
        public var localization: String?
      }
      
      public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<Components.Schemas.NewAndNow.WebToon.CodingKeys> = try decoder.container(keyedBy: Components.Schemas.NewAndNow.WebToon.CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: Components.Schemas.NewAndNow.WebToon.CodingKeys.id)) ?? UUID()
        self.releaseDate = try container.decode(Date.self, forKey: Components.Schemas.NewAndNow.WebToon.CodingKeys.releaseDate)
        self.title = try container.decode(String.self, forKey: Components.Schemas.NewAndNow.WebToon.CodingKeys.title)
        self.thumbnail = try container.decode(String.self, forKey: Components.Schemas.NewAndNow.WebToon.CodingKeys.thumbnail)
        self.thumbnailColor = try container.decode(String.self, forKey: Components.Schemas.NewAndNow.WebToon.CodingKeys.thumbnailColor)
        self.tags = try container.decode([String].self, forKey: Components.Schemas.NewAndNow.WebToon.CodingKeys.tags)
        self.summary = try container.decode(String.self, forKey: Components.Schemas.NewAndNow.WebToon.CodingKeys.summary)
        self.ageRating = try container.decode(String.self, forKey: Components.Schemas.NewAndNow.WebToon.CodingKeys.ageRating)
        self.creators = try container.decode(Components.Schemas.NewAndNow.WebToon.Creators.self, forKey: Components.Schemas.NewAndNow.WebToon.CodingKeys.creators)
      }
    }
    public var comingSoon: [WebToon]
    public var newArrivals: [WebToon]
  }
}
