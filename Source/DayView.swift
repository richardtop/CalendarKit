import UIKit
import Neon
import DateToolsSwift

public protocol DayViewDelegate: AnyObject {
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
  public weak var stateDelegate: DayViewStateUpdating? {
    didSet {
      if let dayViewStateDelegate = stateDelegate {
        state?.subscribe(client: dayViewStateDelegate)
      }
    }
  }

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
  public let customView: UIView?

  public var state: DayViewState? {
    didSet {
      dayHeaderView.state = state
      timelinePagerView.state = state
    }
  }

  public var calendar: Calendar = Calendar.autoupdatingCurrent

  var style = CalendarStyle()

  public init(calendar: Calendar = Calendar.autoupdatingCurrent, customView: UIView? = nil) {
    self.calendar = calendar
    self.dayHeaderView = DayHeaderView(calendar: calendar)
    self.timelinePagerView = TimelinePagerView(calendar: calendar)
    self.customView = customView
    super.init(frame: .zero)
    configure()
  }

  override public init(frame: CGRect) {
    self.dayHeaderView = DayHeaderView(calendar: calendar)
    self.timelinePagerView = TimelinePagerView(calendar: calendar)
    self.customView = nil
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    self.dayHeaderView = DayHeaderView(calendar: calendar)
    self.timelinePagerView = TimelinePagerView(calendar: calendar)
    self.customView = nil
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    if let customView = customView {
      addCustomPagerView(customView)
    } else {
      addSubview(timelinePagerView)
      timelinePagerView.delegate = self
    }
    addSubview(dayHeaderView)

    if state == nil {
      let newState = DayViewState()
      newState.calendar = calendar
      newState.move(to: Date())
      state = newState
    }
  }

  private func addCustomPagerView(_ customView: UIView) {
    customView.translatesAutoresizingMaskIntoConstraints = false
    let trailling = NSLayoutConstraint(item: customView,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: self,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: 0)

    let leading = NSLayoutConstraint(item: customView,
                                     attribute: .leading,
                                     relatedBy: .equal,
                                     toItem: self,
                                     attribute: .leading,
                                     multiplier: 1,
                                     constant: 0)

    let top = NSLayoutConstraint(item: customView,
                                 attribute: .top,
                                 relatedBy: .equal,
                                 toItem: dayHeaderView,
                                 attribute: .bottom,
                                 multiplier: 1,
                                 constant: 0)

    let bottom = NSLayoutConstraint(item: customView,
                                    attribute: .bottom,
                                    relatedBy: .equal,
                                    toItem: self,
                                    attribute: .bottom,
                                    multiplier: 1,
                                    constant: 0)

    self.addConstraint(trailling)
    self.addConstraint(leading)
    self.addConstraint(top)
    self.addConstraint(bottom)

    addSubview(customView)
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
