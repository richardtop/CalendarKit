import UIKit

protocol Reusable: class {
  func prepareForReuse()
}

class PagingScrollView: UIScrollView {

  var reusableViews = [UIView]()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    pagingEnabled = true
    directionalLockEnabled = true
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    recenterIfNecessary()
    realignViews()
  }

  func recenterIfNecessary() {
    if reusableViews.isEmpty { return }
    let contentWidth = contentSize.width
    let centerOffsetX = (contentWidth - bounds.size.width) / 2

    let distanceFromCenter = contentOffset.x - centerOffsetX

    if fabs(distanceFromCenter) > (contentWidth / 3) {
      if distanceFromCenter > 0 {
        reusableViews.shiftRight()
      } else {
        reusableViews.shiftLeft()
      }
      contentOffset = CGPoint(x: centerOffsetX, y: contentOffset.y)
    }
  }

  func realignViews() {
    for (index, subview) in reusableViews.enumerate() {
      subview.frame.origin.x = bounds.width * CGFloat(index)
      subview.frame.size = bounds.size
    }
  }
}

extension Array {
  mutating func shiftLeft() {
    insert(removeFirst(), atIndex: 0)
  }

  mutating func shiftRight() {
    append(removeFirst())
  }
}
