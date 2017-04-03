import UIKit

class TimelineContainer: UIScrollView, ReusableView {

  var timeline: TimelineView!

  override func layoutSubviews() {
    timeline.frame = CGRect(x: 0, y: 0, width: frame.width, height: timeline.fullHeight)
  }

  func prepareForReuse() {
    timeline.prepareForReuse()
  }

  func scrollToFirstEvent() {
    let yToScroll = timeline.firstEventYPosition ?? 0
    setContentOffset(CGPoint(x: contentOffset.x, y: yToScroll), animated: true)
  }
}
