import Foundation

public enum Components {
  public enum Schemas { }
}

extension Components.Schemas {
  public struct NewAndNow: Codable, Sendable, Equatable {
    // TODO: - Shared Model로 빼기
    public struct WebToon: Sendable, Equatable, Identifiable {
      public var id: UUID
      public var releaseDate: Date?
      public var title: String
      public var thumbnail: URL?
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
      
      public var episodes: [Episode]
      public struct Episode: Sendable, Equatable, Identifiable {
        public var id: String { title }
        public var title: String
        public var thumbnail: URL?
        public init(title: String, thumbnail: URL? = nil) {
          self.title = title
          self.thumbnail = thumbnail
        }
      }
      public var isNewSeason: Bool?
    }
    public var comingSoon: [WebToon]
    public var newArrivals: [WebToon]
  }
}

// MARK: - WebToon Codable
extension Components.Schemas.NewAndNow.WebToon: Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
    self.releaseDate = try container.decodeIfPresent(Date.self, forKey: .releaseDate)
    self.title = try container.decode(String.self, forKey: .title)
    let urlString = try container.decode(String.self, forKey: .thumbnail)
    self.thumbnail = URL(string: urlString)
    self.thumbnailColor = try container.decode(String.self, forKey: .thumbnailColor)
    self.tags = try container.decode([String].self, forKey: .tags)
    self.summary = try container.decode(String.self, forKey: .summary)
    self.ageRating = try container.decode(String.self, forKey: .ageRating)
    self.creators = try container.decode(Components.Schemas.NewAndNow.WebToon.Creators.self, forKey: .creators)
    self.episodes = (try? container.decode([Episode].self, forKey: .episodes)) ?? []
    if let isNewSeasonString = try? container.decode(String.self, forKey: .isNewSeason) {
        self.isNewSeason = isNewSeasonString.lowercased() == "true"
    } else {
        self.isNewSeason = try container.decodeIfPresent(Bool.self, forKey: .isNewSeason)
    }
  }
}

// MARK: - Episode Codable
extension Components.Schemas.NewAndNow.WebToon.Episode: Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: Components.Schemas.NewAndNow.WebToon.Episode.CodingKeys.self)
    self.title = try container.decode(String.self, forKey: .title)
    let urlString = try container.decode(String.self, forKey: .thumbnail)
    self.thumbnail = URL(string: urlString)
  }
}
