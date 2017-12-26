import UIKit

class TimelineContainer: UIScrollView, ReusableView {
  
  let timeline: TimelineView
  
  init(_ timeline: TimelineView) {
    self.timeline = timeline
    super.init(frame: .zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    timeline.frame = CGRect(x: 0, y: 0, width: frame.width, height: timeline.fullHeight)
  }
  
  func prepareForReuse() {
    timeline.prepareForReuse()
  }
  
  func scrollToFirstEvent() {
    if let yToScroll = timeline.firstEventYPosition {
      setContentOffset(CGPoint(x: contentOffset.x, y: yToScroll - 15), animated: true)
    }
  }
  
  func scrollTo(hour24: Float) {
    let percentToScroll = CGFloat(hour24 / 24)
    let yToScroll = contentSize.height * percentToScroll
    let padding: CGFloat = 8
    setContentOffset(CGPoint(x: contentOffset.x, y: yToScroll - padding), animated: true)
  }
}
