import SwiftUI

public struct ChipLayout: Layout {
  let horizontalSpacing: CGFloat
  let verticalSpacing: CGFloat
  
  public init(
    horizontalSpacing: CGFloat,
    verticalSpacing: CGFloat
  ) {
    self.horizontalSpacing = horizontalSpacing
    self.verticalSpacing = verticalSpacing
  }
  
  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    var sumX: CGFloat = 0
    var sumY: CGFloat = 0
    var maxHeight: CGFloat = 0
    
    for view in subviews {
      guard let proposalWidth = proposal.width else { continue }
      let viewSize = view.sizeThatFits(.unspecified)
      
      if sumX + viewSize.width > proposalWidth {
        sumX = 0
        sumY += maxHeight + verticalSpacing
        maxHeight = 0
      }
      maxHeight = max(maxHeight, viewSize.height)
      sumX += viewSize.width + horizontalSpacing
    }
    sumY += maxHeight
    
    return CGSize(width: proposal.width ?? 0, height: sumY)
  }
  
  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    var sumX = bounds.minX
    var sumY = bounds.minY
    
    for view in subviews {
      guard let prposalWidth = proposal.width else { continue }
      let viewSize = view.sizeThatFits(.unspecified)
  
      if sumX + viewSize.width > prposalWidth {
        sumX = bounds.minX
        sumY += viewSize.height
        sumY += verticalSpacing
      }
      view.place(
        at: .init(x: sumX, y: sumY),
        anchor: .topLeading,
        proposal: proposal
      )
      sumX += (viewSize.width + horizontalSpacing)
    }
  }
}
