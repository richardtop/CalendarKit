import UIKit

public final class TimelineContainer: UIScrollView {
  public let timeline: TimelineView
    weak var parent: UIViewController?
  
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
            
        }
        
        if parent.children.count == 1 {
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
      print("___ from layoutSubviews", contentOffset.y)
      if contentOffset.y < 5 {
          print()
      }
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
        let allDayViewHeight = timeline.allDayViewHeight
        let padding = allDayViewHeight + 200
        if let yToScroll = timeline.currentTimeYPosition {
            setTimelineOffset(CGPoint(x: contentOffset.x, y: yToScroll - padding), animated: animated)
        }
    }
  
  public func scrollTo(hour24: Float, animated: Bool = true) {
    let percentToScroll = CGFloat(hour24 / 24)
    let yToScroll = contentSize.height * percentToScroll
    let padding: CGFloat = 8
    setTimelineOffset(CGPoint(x: contentOffset.x, y: yToScroll - padding), animated: animated)
  }
    
    public func scrollTo(offSet: CGPoint, animated: Bool = false) {
        setTimelineOffset(offSet, animated: animated)
    }

  private func setTimelineOffset(_ offset: CGPoint, animated: Bool) {
    let yToScroll = offset.y
    let bottomOfScrollView = contentSize.height - bounds.size.height
    let newContentY = (yToScroll < bottomOfScrollView) ? yToScroll : bottomOfScrollView
    setContentOffset(CGPoint(x: offset.x, y: newContentY), animated: animated)
  }
}
