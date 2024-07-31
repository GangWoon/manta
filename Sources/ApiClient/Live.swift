import Dependencies

extension ApiClient: DependencyKey {
  /// 서버가 없기 때문에 json 파일을 통해 데이터를 전달받는걸로 대체합니다.
  public static let liveValue: ApiClient = Self.mock
}
