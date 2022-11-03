import UIKit

public final class TimelineContainer: UIScrollView {
  public let timeline: TimelineView
  unowned var parent: UIViewController?
    
    var timeIntervalBefore: Float {
        if let parent = parent?.parent as? CKPageViewController {
            return parent.timeIntervalBefore
        }
        return .zero
    }
  
  public init(_ timeline: TimelineView) {
    self.timeline = timeline
    super.init(frame: .zero)
  }
  
  @available(*, unavailable)
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
    public override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        guard let parent = parent?.parent as? CKPageViewController else { return }
        
        if let offset = parent.commonOffset {
            super.setContentOffset(offset, animated: animated)
            return
        }
        
        if parent.children.count == 1 {
            parent.commonOffset = contentOffset
            super.setContentOffset(contentOffset, animated: animated)
        }
        
        if parent.children.count != 1,
           parent.commonOffset == nil {
            super.setContentOffset(contentOffset, animated: animated)
        }
    }
    
  override public func layoutSubviews() {
    super.layoutSubviews()
    timeline.frame = CGRect(x: 0, y: 0, width: bounds.width, height: timeline.fullHeight)

    timeline.offsetAllDayView(by: contentOffset.y)
    
    //adjust the scroll insets
    let allDayViewHeight = timeline.allDayViewHeight
    let bottomSafeInset = window?.safeAreaInsets.bottom ?? 0

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
    
    public func scroollToCurrentTime(animated: Bool) {
        let timeToScroll = Date().timeOnly() - timeIntervalBefore
        scrollTo(hour24: timeToScroll, animated: animated)
    }
  
  public func scrollTo(hour24: Float, animated: Bool = true) {
    let percentToScroll = CGFloat(hour24 / 24)
    let yToScroll = contentSize.height * percentToScroll
    setTimelineOffset(CGPoint(x: contentOffset.x, y: yToScroll), animated: animated)
  }

    private func setTimelineOffset(_ offset: CGPoint, animated: Bool) {
        let yToScroll = offset.y
        let bottomOfScrollView = contentSize.height - bounds.size.height
        
        var newContentY: CGFloat = yToScroll
        if yToScroll < bottomOfScrollView {
            newContentY = (yToScroll < frame.minY) ? frame.minY : yToScroll
        } else {
            newContentY = bottomOfScrollView
        }
        
        if let parent = parent?.parent as? CKPageViewController {
            parent.commonOffset?.y = newContentY
        }
        setContentOffset(CGPoint(x: offset.x, y: newContentY), animated: animated)
    }
}
