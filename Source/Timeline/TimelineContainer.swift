import UIKit

class TimelineContainer: UIScrollView {

  var timeline: TimelineView!

  override func layoutSubviews() {
    timeline.frame = CGRect(x: 0, y: 0, width: frame.width, height: timeline.fullHeight)
  }
}

extension TimelineContainer: ReusableView {
  func prepareForReuse() {
    timeline.prepareForReuse()
  }
}