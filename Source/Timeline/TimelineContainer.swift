import UIKit

public final class TimelineContainer: UIScrollView {
  public let timeline: TimelineView
  
  public init(_ timeline: TimelineView) {
    self.timeline = timeline
    super.init(frame: .zero)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    timeline.frame = CGRect(x: 0, y: 0, width: bounds.width, height: timeline.fullHeight)
    timeline.offsetAllDayView(by: contentOffset.y)
    
    
    //adjust the scroll insets
    let allDayViewHeight = timeline.allDayViewHeight
    let bottomSafeInset: CGFloat
    if #available(iOS 11.0, *) {
      bottomSafeInset = window?.safeAreaInsets.bottom ?? 0
    } else {
      bottomSafeInset = 0
    }
    scrollIndicatorInsets = UIEdgeInsets(top: allDayViewHeight, left: 0, bottom: bottomSafeInset, right: 0)
    contentInset = UIEdgeInsets(top: allDayViewHeight, left: 0, bottom: bottomSafeInset, right: 0)
  }
  
  public func prepareForReuse() {
    timeline.prepareForReuse()
  }
  
  public func scrollToFirstEvent(animated: Bool) {
    let allDayViewHeight = timeline.allDayViewHeight
    let padding = allDayViewHeight + 8
    if let yToScroll = timeline.firstEventYPosition {
      setTimelineOffset(CGPoint(x: contentOffset.x, y: yToScroll - padding), animated: animated)
    }
  }
  
  public func scrollTo(hour24: Float, animated: Bool = true) {
    let percentToScroll = CGFloat(hour24 / 24)
    let yToScroll = contentSize.height * percentToScroll
    let padding: CGFloat = 8
    setTimelineOffset(CGPoint(x: contentOffset.x, y: yToScroll - padding), animated: animated)
  }

  private func setTimelineOffset(_ offset: CGPoint, animated: Bool) {
    let yToScroll = offset.y
    let bottomOfScrollView = contentSize.height - bounds.size.height
    let newContentY = (yToScroll < bottomOfScrollView) ? yToScroll : bottomOfScrollView
    setContentOffset(CGPoint(x: offset.x, y: newContentY), animated: animated)
  }
}
