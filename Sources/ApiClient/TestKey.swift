import Dependencies
import Foundation

extension DependencyValues {
  public var apiClient: ApiClient {
    get { self[ApiClient.self] }
    set { self[ApiClient.self] = newValue }
  }
}

extension ApiClient: TestDependencyKey {
  static public let previewValue: ApiClient = ApiClient.mock
  static public let testValue: ApiClient = .init()
}

extension ApiClient {
  public static let mock = Self {
    guard
      let path = Bundle.module.path(forResource: "data", ofType: "json")
    else { throw _Error.unexpected }
    let data = try Data(contentsOf: URL(filePath: path))
    return try .ok(.init(body: .json(decode(data))))
  }
}

private enum _Error: Error {
  case unexpected
}

private func decode<T: Decodable>(_ data: Data) throws -> T {
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  decoder.dateDecodingStrategy = .iso8601
  return try decoder.decode(T.self, from: data)
}
