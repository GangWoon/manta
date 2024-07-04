import SwiftUI

public struct WiggleModifier: ViewModifier {
  var isSelected: Bool
  let animationDuration: CGFloat = 0.2
  
  @State private var currentState: WiggleStatus = .none
  enum WiggleStatus: Equatable {
    var degree: CGFloat {
      switch self {
      case .none:
        return 0
      case .left(let intensity):
        return intensity * -4
      case .right(let intensity):
        return intensity * 4
      }
    }
    case none
    case left(CGFloat)
    case right(CGFloat)
    
    mutating func update(withIntensity intensity: CGFloat) {
      switch self {
      case .none, .right:
        self = .left(intensity)
      case .left:
        self = .right(intensity)
      }
    }
    
    mutating func reset() {
      self = .none
    }
  }
  
  @State private var task: Task<Void, Never>?
  
  public init(isSelected: Bool) {
    self.isSelected = isSelected
  }
  
  public func body(content: Content) -> some View {
    content
      .rotationEffect(.degrees(currentState.degree), anchor: .top)
      .onChange(of: isSelected) { newValue in
        if newValue {
          task = buildTask()
        } else {
          cancelTask()
          currentState.reset()
        }
      }
      .animation(
        .easeInOut(duration: animationDuration),
        value: currentState
      )
  }
  
  private func buildTask() -> Task<Void, Never> {
    Task {
      defer {
        task = nil
        currentState.reset()
      }
      
      do {
        var maxCount = 6.0
        while !isSelected && maxCount > 0 {
          maxCount -= 1
          try await Task.sleep(for: .seconds(animationDuration))
          currentState.update(withIntensity: maxCount)
        }
      } catch { }
    }
  }
  
  private func cancelTask() {
    task?.cancel()
    task = nil
  }
}

public extension View {
  func wiggleAnimation(isSelected: Bool) -> some View {
    modifier(WiggleModifier(isSelected: isSelected))
  }
}

@available(iOS 18.0, *)
#Preview {
  @Previewable @State var isSelected: Bool = false
  
  Button(action: { isSelected.toggle() }) {
    Image(
      systemName: isSelected
      ? "bell.fill"
      : "bell"
    )
  }
  .wiggleAnimation(isSelected: isSelected)
}
