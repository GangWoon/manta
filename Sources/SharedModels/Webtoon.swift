import Foundation

public struct Webtoon: Identifiable, Sendable, Equatable {
  public var id: UUID
  public var releaseDate: Date?
  public var title: String
  public var thumbnail: URL?
  public var thumbnailSmall: URL?
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
    
    public init(
      production: String? = nil,
      illustration: String? = nil,
      writer: String? = nil,
      originalStory: String? = nil,
      localization: String? = nil
    ) {
      self.production = production
      self.illustration = illustration
      self.writer = writer
      self.originalStory = originalStory
      self.localization = localization
    }
  }
  
  public var episodes: [Episode]
  public struct Episode: Identifiable, Sendable, Equatable {
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

extension Webtoon: Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
    self.releaseDate = try container.decodeIfPresent(Date.self, forKey: .releaseDate)
    self.title = try container.decode(String.self, forKey: .title)
    let urlString = try container.decode(String.self, forKey: .thumbnail)
    self.thumbnail = URL(string: urlString)
    if let thumbnailSmallUrlString = try container.decodeIfPresent(String.self, forKey: .thumbnailSmall) {
      self.thumbnailSmall = URL(string: thumbnailSmallUrlString)
    }
    self.thumbnailColor = try container.decode(String.self, forKey: .thumbnailColor)
    self.tags = try container.decode([String].self, forKey: .tags)
    self.summary = try container.decode(String.self, forKey: .summary)
    self.ageRating = try container.decode(String.self, forKey: .ageRating)
    self.creators = try container.decode(Creators.self, forKey: .creators)
    self.episodes = (try? container.decode([Episode].self, forKey: .episodes)) ?? []
    if let isNewSeasonString = try? container.decode(String.self, forKey: .isNewSeason) {
        self.isNewSeason = isNewSeasonString.lowercased() == "true"
    } else {
        self.isNewSeason = try container.decodeIfPresent(Bool.self, forKey: .isNewSeason)
    }
  }
}

// MARK: - Episode Codable
extension Webtoon.Episode: Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: Webtoon.Episode.CodingKeys.self)
    self.title = try container.decode(String.self, forKey: .title)
    let urlString = try container.decode(String.self, forKey: .thumbnail)
    self.thumbnail = URL(string: urlString)
  }
}
