import SwiftUI

struct DragObservingScrollView<Content: View>: UIViewRepresentable {
  @Binding var isDragExceeding: Bool
  @ViewBuilder var content: Content
  
  @State private var startDragOffset: CGFloat = .zero
  
  init(
    isDragExceeding: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self._isDragExceeding = isDragExceeding
    self.content = content()
  }
  
  func makeUIView(context: Context) -> UIScrollView {
    let scrollView = buildScrollView()
    scrollView.delegate = context.coordinator
    let hostingController = UIHostingController(rootView: content)
    context.coordinator.hostingController = hostingController
    layoutContent(hostingController: hostingController, target: scrollView)
    return scrollView
  }
  
  private func buildScrollView() -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    return scrollView
  }
  
  private func layoutContent(
    hostingController: UIHostingController<Content>,
    target view: UIView
  ) {
    view.addSubview(hostingController.view)
    
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      hostingController.view.widthAnchor.constraint(equalTo: view.widthAnchor)
    ])
  }
  
  func updateUIView(_ scrollView: UIScrollView, context: Context) {
    guard 
      let hostingController = context.coordinator.hostingController
    else { return }
    hostingController.rootView = content
    refreshContentLayout(
      hostingController: hostingController,
      scrollView: scrollView
    )
  }
  
  private func refreshContentLayout(
    hostingController: UIHostingController<Content>,
    scrollView: UIScrollView
  ) {
    hostingController.view.invalidateIntrinsicContentSize()
    hostingController.view.setNeedsLayout()
    hostingController.view.layoutIfNeeded()
    scrollView.contentSize = hostingController.view.intrinsicContentSize
    
    guard scrollView.contentOffset.y != 0 else { return }
    scrollView.setContentOffset(.zero, animated: false)
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  final class Coordinator: NSObject, UIScrollViewDelegate {
    var parent: DragObservingScrollView
    var hostingController: UIHostingController<Content>?
    
    init(_ parent: DragObservingScrollView) {
      self.parent = parent
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      parent.startDragOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      let threshold = 50.0
      let value = scrollView.contentOffset.y - parent.startDragOffset
      if value > threshold {
        parent.isDragExceeding = true
      } else if value < -threshold {
        parent.isDragExceeding = false
      }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
      guard !decelerate else { return }
      resetDragOffset()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      resetDragOffset()
    }
    
    private func resetDragOffset() {
      parent.startDragOffset = .zero
    }
  }
}
