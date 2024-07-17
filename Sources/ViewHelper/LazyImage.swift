import Perception
import SwiftUI

public struct LazyImage<Content: View>: View {
  @State private var phase: LazyImagePhase = .empty
  public enum LazyImagePhase {
    public var image: Image? {
      guard case let .success(image) = self else { return nil }
      return image
    }
    public var error: Error? {
      guard case let .failure(error) = self else { return nil }
      return error
    }
    
    case empty
    case success(Image)
    case failure(Error)
  }
  private let imageCache: ImageCache = .shared
  private var url: URL?
  private var content: (LazyImagePhase) -> Content
  
  public init<I, P>(
    url: URL? = nil,
    content: @escaping (Image) -> I,
    placeholder: @escaping () -> P
  ) where Content == _ConditionalContent<I, P> {
    self.url = url
    self.content = { phase -> _ConditionalContent<I, P> in
      if let image = phase.image {
        return ViewBuilder.buildEither(first: content(image))
      } else {
        return ViewBuilder.buildEither(second: placeholder())
      }
    }
  }
  
  public var body: some View {
    WithPerceptionTracking {
      content(phase)
        .task(id: url) {
          do {
            try await fetch()
          } catch {
            phase = .failure(error)
          }
        }
    }
  }
  
  private func fetch() async throws {
    guard
      let url,
      let uiimage = UIImage(data: try await imageCache.fetch(url))
    else { return }
    phase = .success(Image(uiImage: uiimage))
  }
}

private actor ImageCache {
  static let shared = ImageCache()
  private var cache: NSCache<NSString, Entry.Object> = .init()
  enum Entry {
    final class Object {
      let entry: Entry
      init(entry: Entry) {
        self.entry = entry
      }
    }
    case inProgress(Task<Data, Error>)
    case ready(Data)
  }
  
  private init() { }
  
  func fetch(_ url: URL) async throws -> Data {
    let key = url.absoluteString as NSString
    if let value = cache.object(forKey: key) {
      switch value.entry {
      case let .inProgress(task):
        return try await task.value
        
      case let .ready(data):
        return data
      }
    } else {
      let task = Task {
        do {
          return try await URLSession.shared.data(from:url).0
        } catch {
          cache.removeObject(forKey: key)
          throw error
        }
      }
      cache.setObject(.init(entry: .inProgress(task)), forKey: key)
      return try await withTaskCancellationHandler {
        let result  = try await task.value
        cache.setObject(.init(entry: .ready(result)), forKey: key)
        return result
      } onCancel: {
        task.cancel()
      }
    }
  }
}
