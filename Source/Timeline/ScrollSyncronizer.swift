import UIKit

class ScrollSynchronizer: NSObject, UIScrollViewDelegate {

  var views = [UIScrollView]()

  init(views: [UIScrollView] = [UIScrollView]()) {
    self.views = views
    super.init()
    views.forEach{$0.delegate = self}
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let contentOffset = scrollView.contentOffset
    for view in views {
      if view == scrollView {continue}
      view.contentOffset = contentOffset
    }
  }
}
