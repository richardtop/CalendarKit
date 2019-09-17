import UIKit
import Neon
import DateToolsSwift

public protocol DayViewDelegate: AnyObject {
  func dayViewDidSelectEventView(_ eventView: EventView)
  func dayViewDidLongPressEventView(_ eventView: EventView)
  func dayViewDidTapTimeline(dayView: DayView)
  func dayView(dayView: DayView, didLongPressTimelineAt date: Date)
  func dayView(dayView: DayView, willMoveTo date: Date)
  func dayView(dayView: DayView, didMoveTo  date: Date)
  func dayView(dayView: DayView, didUpdate event: EventDescriptor)
}

public class DayView: UIView, EventViewDelegate, TimelinePagerViewDelegate {

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

  let dayHeaderView: DayHeaderView
  let timelinePagerView: TimelinePagerView

  public var state: DayViewState? {
    didSet {
      dayHeaderView.state = state
      timelinePagerView.state = state
    }
  }

  public var calendar: Calendar = Calendar.autoupdatingCurrent

  var style = CalendarStyle()

  public init(calendar: Calendar = Calendar.autoupdatingCurrent) {
    self.calendar = calendar
    self.dayHeaderView = DayHeaderView(calendar: calendar)
    self.timelinePagerView = TimelinePagerView(calendar: calendar)
    super.init(frame: .zero)
    configure()
  }

  override public init(frame: CGRect) {
    self.dayHeaderView = DayHeaderView(calendar: calendar)
    self.timelinePagerView = TimelinePagerView(calendar: calendar)
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    self.dayHeaderView = DayHeaderView(calendar: calendar)
    self.timelinePagerView = TimelinePagerView(calendar: calendar)
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    addSubview(timelinePagerView)
    addSubview(dayHeaderView)
    timelinePagerView.delegate = self

    if state == nil {
      let newState = DayViewState()
      newState.calendar = calendar
      newState.move(to: Date())
      state = newState
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
    dayHeaderView.anchorAndFillEdge(.top, xPad: 0, yPad: layoutMargins.top, otherSize: headerHeight)
    timelinePagerView.alignAndFill(align: .underCentered, relativeTo: dayHeaderView, padding: 0)
  }

  public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
    dayHeaderView.transitionToHorizontalSizeClass(sizeClass)
    updateStyle(style)
  }

  public func create(event: EventDescriptor, animated: Bool = false) {
    timelinePagerView.create(event: event, animated: animated)
  }

  public func beginEditing(event: EventDescriptor, animated: Bool = false) {
    timelinePagerView.beginEditing(event: event, animated: animated)
  }

  public func cancelPendingEventCreation() {
    timelinePagerView.cancelPendingEventCreation()
  }

  // MARK: EventViewDelegate

  public func eventViewDidTap(_ eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  public func eventViewDidLongPress(_ eventview: EventView) {
    delegate?.dayViewDidLongPressEventView(eventview)
  }

  // MARK: TimelinePagerViewDelegate

  public func timelinePagerDidSelectEventView(_ eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  public func timelinePagerDidLongPressEventView(_ eventView: EventView) {
    delegate?.dayViewDidLongPressEventView(eventView)
  }
  public func timelinePager(timelinePager: TimelinePagerView, willMoveTo date: Date) {
    delegate?.dayView(dayView: self, willMoveTo: date)
  }
  public func timelinePager(timelinePager: TimelinePagerView, didMoveTo  date: Date) {
    delegate?.dayView(dayView: self, didMoveTo: date)
  }
  public func timelinePager(timelinePager: TimelinePagerView, didLongPressTimelineAt date: Date) {
    delegate?.dayView(dayView: self, didLongPressTimelineAt: date)
  }
  public func timelinePagerDidTap(timelinePager: TimelinePagerView) {
    delegate?.dayViewDidTapTimeline(dayView: self)
  }
  public func timelinePager(timelinePager: TimelinePagerView, didUpdate event: EventDescriptor) {
    delegate?.dayView(dayView: self, didUpdate: event)
  }
}
