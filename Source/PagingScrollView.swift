import UIKit

protocol PagingScrollViewDelegate: class {
  func viewRequiresUpdate(view: UIView, viewBefore: UIView)
  func viewRequiresUpdate(view: UIView, viewAfter: UIView)
}

class PagingScrollView: UIScrollView {

  weak var viewDelegate: PagingScrollViewDelegate?

  var currentPage: CGFloat {
    get {
      let width = bounds.width
      let centerOffsetX = contentOffset.x + width / 2
      return centerOffsetX / width
    }
  }

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
    delegate = self
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
        reusableViews.shift(1)
        viewDelegate?.viewRequiresUpdate(reusableViews[2], viewBefore: reusableViews[1])
      } else {
        reusableViews.shift(-1)
        viewDelegate?.viewRequiresUpdate(reusableViews[0], viewAfter: reusableViews[1])
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

extension PagingScrollView: UIScrollViewDelegate {
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let pageWidth = scrollView.frame.size.width;
    let fractionalPage = scrollView.contentOffset.x / pageWidth;

    }
  }

