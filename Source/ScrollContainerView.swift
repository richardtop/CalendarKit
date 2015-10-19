import UIKit

class ScrollContainerView: UIScrollView {

  var reusableViews = [UIView]()

  override func layoutSubviews() {
    super.layoutSubviews()
    recenterIfNecessary()
  }

  func recenterIfNecessary() {
    let contentWidth = contentSize.width
    let centerOffsetX = (contentWidth - bounds.size.width) / 2

    let distanceFromCenter = contentOffset.x - centerOffsetX

    if fabs(distanceFromCenter) > (contentWidth / 3) {
      contentOffset = CGPoint(x: centerOffsetX, y: contentOffset.y)

      //TODO: refactor maybe ? i.e. shiftRight // ShiftLeft
      if distanceFromCenter > 0 {
        let element = reusableViews.removeFirst()
        reusableViews.append(element)
        reusableViews = Array(reusableViews)
      } else {
        let element = reusableViews.removeLast()
        reusableViews.insert(element, atIndex: 0)
        reusableViews = Array(reusableViews)
      }

      for (index, subview) in reusableViews.enumerate() {
        subview.frame.origin.x = bounds.width * CGFloat(index)
      }
    }
  }
}
