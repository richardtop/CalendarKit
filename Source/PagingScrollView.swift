import UIKit

protocol PagingScrollViewDelegate: class {
  func updateViewAtIndex(index: Int)
  func scrollviewDidScrollToViewAtIndex(index: Int)
}

protocol ReusableView: class {
  func prepareForReuse()
}

extension UIView: ReusableView {
  func prepareForReuse() {}
}

class PagingScrollView<T: UIView where T: ReusableView>: UIScrollView, UIScrollViewDelegate {

  var reusableViews = [T]()
  weak var viewDelegate: PagingScrollViewDelegate?

  var previousPage: CGFloat = 1
  var currentScrollViewPage: CGFloat {
    get {
      let width = bounds.width
      let centerOffsetX = contentOffset.x + width / 2
      return centerOffsetX / width - 0.5
    }
  }

  var accumulator: CGFloat = 0
  var currentIndex: CGFloat {
    return round(currentScrollViewPage) + accumulator
  }

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
    delegate = self
    // TODO: Play with deceleration rate to match calendar speed
    decelerationRate = 50
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
      recenter()
    }
  }

  func recenter() {
    let contentWidth = contentSize.width
    let centerOffsetX = (contentWidth - bounds.size.width) / 2
    let distanceFromCenter = contentOffset.x - centerOffsetX

    if distanceFromCenter > 0 {
      reusableViews.shift(1)
      accumulator++
      reusableViews.last!.prepareForReuse()
      viewDelegate?.updateViewAtIndex(reusableViews.endIndex - 1)
    } else if distanceFromCenter < 0 {
      reusableViews.shift(-1)
      accumulator--
      reusableViews.first!.prepareForReuse()
      viewDelegate?.updateViewAtIndex(0)
    }
    contentOffset = CGPoint(x: centerOffsetX, y: contentOffset.y)
  }

  func realignViews() {
    for (index, subview) in reusableViews.enumerate() {
      subview.frame.origin.x = bounds.width * CGFloat(index)
      subview.frame.size = bounds.size
    }
  }

  func scrollForward() {
    setContentOffset(CGPoint(x: contentOffset.x + bounds.width, y: 0), animated: true)
  }

  func scrollBackward() {
    setContentOffset(CGPoint(x: contentOffset.x - bounds.width, y: 0), animated: true)
  }

  func checkForPageChange() {
    if currentIndex != previousPage {
      viewDelegate?.scrollviewDidScrollToViewAtIndex(Int(currentScrollViewPage))
      //TODO: re-think reuse engine
      reusableViews.filter { $0 != reusableViews[Int(currentScrollViewPage)]}.forEach {$0.prepareForReuse()}
      previousPage = currentIndex
    }
    recenter()
  }

  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if decelerate {return}
    checkForPageChange()
  }

  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    checkForPageChange()
  }

  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    checkForPageChange()
  }
}
