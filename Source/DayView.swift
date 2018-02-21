import UIKit
import Neon
import DateToolsSwift

public protocol DayViewDelegate: class {
  func dayViewDidSelectEventView(_ eventView: EventView)
  func dayViewDidLongPressEventView(_ eventView: EventView)
  func dayViewDidLongPressTimelineAtHour(_ hour: Int)
  func dayView(dayView: DayView, willMoveTo date: Date)
  func dayView(dayView: DayView, didMoveTo  date: Date)
}

public class DayView: UIView {

  public weak var dataSource: EventDataSource? {
    get {
      return timelinePagerView.dataSource
    }
    set(value) {
      timelinePagerView.dataSource = value
    }
  }

  public weak var delegate: DayViewDelegate?

  /// Hides or shows header view
  public var isHeaderViewVisible = true {
    didSet {
      headerHeight = isHeaderViewVisible ? DayView.headerVisibleHeight : 0
      dayHeaderView.isHidden = !isHeaderViewVisible
      setNeedsLayout()
    }
  }

  public var timelineScrollOffset: CGPoint {
    return timelinePagerView.timelineScrollOffset
  }

  static let headerVisibleHeight: CGFloat = 88
  var headerHeight: CGFloat = headerVisibleHeight

  open var autoScrollToFirstEvent: Bool {
    get {
      return timelinePagerView.autoScrollToFirstEvent
    }
    set (value) {
      timelinePagerView.autoScrollToFirstEvent = value
    }
  }

  let dayHeaderView = DayHeaderView()
  let timelinePagerView = TimelinePagerView()

  public var state: DayViewState? {
    didSet {
      dayHeaderView.state = state
      timelinePagerView.state = state
    }
  }

  var style = CalendarStyle()

  public init(state: DayViewState) {
    super.init(frame: .zero)
    self.state = state
    configure()
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    addSubview(timelinePagerView)
    addSubview(dayHeaderView)
    timelinePagerView.delegate = self

    if state == nil {
      state = DayViewState()
    }
  }

  public func updateStyle(_ newStyle: CalendarStyle) {
    style = newStyle.copy() as! CalendarStyle
    dayHeaderView.updateStyle(style.header)
    timelinePagerView.updateStyle(style.timeline)
  }

  public func timelinePanGestureRequire(toFail gesture: UIGestureRecognizer) {
    timelinePagerView.timelinePanGestureRequire(toFail: gesture)
  }

  public func scrollTo(hour24: Float) {
    timelinePagerView.scrollTo(hour24: hour24)
  }

  public func scrollToFirstEventIfNeeded() {
    timelinePagerView.scrollToFirstEventIfNeeded()
  }

  public func reloadData() {
    timelinePagerView.reloadData()
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    dayHeaderView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: headerHeight)
    timelinePagerView.alignAndFill(align: .underCentered, relativeTo: dayHeaderView, padding: 0)
  }

  public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
    dayHeaderView.transitionToHorizontalSizeClass(sizeClass)
    updateStyle(style)
  }
}

extension DayView: EventViewDelegate {
  public func eventViewDidTap(_ eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  public func eventViewDidLongPress(_ eventview: EventView) {
    delegate?.dayViewDidLongPressEventView(eventview)
  }
}

extension DayView: TimelinePagerViewDelegate {
  public func timelinePagerDidSelectEventView(_ eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  public func timelinePagerDidLongPressEventView(_ eventView: EventView) {
    delegate?.dayViewDidLongPressEventView(eventView)
  }
  public func timelinePagerDidLongPressTimelineAtHour(_ hour: Int) {
    delegate?.dayViewDidLongPressTimelineAtHour(hour)
  }
  public func timelinePager(timelinePager: TimelinePagerView, willMoveTo date: Date) {
    delegate?.dayView(dayView: self, willMoveTo: date)
  }
  public func timelinePager(timelinePager: TimelinePagerView, didMoveTo  date: Date) {
    delegate?.dayView(dayView: self, didMoveTo: date)
  }
}

extension DayView: TimelineViewDelegate {
  public func timelineView(_ timelineView: TimelineView, didLongPressAt hour: Int) {
    delegate?.dayViewDidLongPressTimelineAtHour(hour)
  }
}
