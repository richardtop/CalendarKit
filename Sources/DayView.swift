import UIKit

public protocol DayViewDelegate: AnyObject {
  func dayViewDidSelectEventView(_ eventView: EventView)
  func dayViewDidLongPressEventView(_ eventView: EventView)
  func dayView(dayView: DayView, didTapTimelineAt date: Date)
  func dayView(dayView: DayView, didLongPressTimelineAt date: Date)
  func dayViewDidBeginDragging(dayView: DayView)
  func dayViewDidTransitionCancel(dayView: DayView)
  func dayView(dayView: DayView, willMoveTo date: Date)
  func dayView(dayView: DayView, didMoveTo  date: Date)
  func dayView(dayView: DayView, didUpdate event: EventDescriptor)
}

public class DayView: UIView, TimelinePagerViewDelegate {
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

  private static let headerVisibleHeight: CGFloat = 88
  public var headerHeight: CGFloat = headerVisibleHeight

  public var autoScrollToFirstEvent: Bool {
    get {
      return timelinePagerView.autoScrollToFirstEvent
    }
    set (value) {
      timelinePagerView.autoScrollToFirstEvent = value
    }
  }

  public let dayHeaderView: DayHeaderView
  public let timelinePagerView: TimelinePagerView

  public var state: DayViewState? {
    didSet {
      dayHeaderView.state = state
      timelinePagerView.state = state
    }
  }

  public var calendar: Calendar = Calendar.autoupdatingCurrent

  public var eventEditingSnappingBehavior: EventEditingSnappingBehavior {
    get {
      timelinePagerView.eventEditingSnappingBehavior
    }
    set {
      timelinePagerView.eventEditingSnappingBehavior = newValue
    }
  }

  private var style = CalendarStyle()

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

  private func configure() {
    addSubview(timelinePagerView)
    addSubview(dayHeaderView)
    configureLayout()
    timelinePagerView.delegate = self

    if state == nil {
      let newState = DayViewState(date: Date(), calendar: calendar)
      newState.move(to: Date())
      state = newState
    }
  }
  
  private func configureLayout() {
    if #available(iOS 11.0, *) {
      dayHeaderView.translatesAutoresizingMaskIntoConstraints = false
      timelinePagerView.translatesAutoresizingMaskIntoConstraints = false
      
      dayHeaderView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
      dayHeaderView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
      dayHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
      let heightConstraint = dayHeaderView.heightAnchor.constraint(equalToConstant: headerHeight)
      heightConstraint.priority = .defaultLow
      heightConstraint.isActive = true
      
      timelinePagerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
      timelinePagerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
      timelinePagerView.topAnchor.constraint(equalTo: dayHeaderView.bottomAnchor).isActive = true
      timelinePagerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
  }

  public func updateStyle(_ newStyle: CalendarStyle) {
    style = newStyle
    dayHeaderView.updateStyle(style.header)
    timelinePagerView.updateStyle(style.timeline)
  }

  public func timelinePanGestureRequire(toFail gesture: UIGestureRecognizer) {
    timelinePagerView.timelinePanGestureRequire(toFail: gesture)
  }

  public func scrollTo(hour24: Float, animated: Bool = true) {
    timelinePagerView.scrollTo(hour24: hour24, animated: animated)
  }

  public func scrollToFirstEventIfNeeded(animated: Bool = true) {
    timelinePagerView.scrollToFirstEventIfNeeded(animated: animated)
  }

  public func reloadData() {
    timelinePagerView.reloadData()
  }
  
  public func move(to date: Date) {
    state?.move(to: date)
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    if #available(iOS 11, *) {} else {
      dayHeaderView.frame = CGRect(origin: CGPoint(x: 0, y: layoutMargins.top),
                                   size: CGSize(width: bounds.width, height: headerHeight))
      let timelinePagerHeight = bounds.height - dayHeaderView.frame.maxY
      timelinePagerView.frame = CGRect(origin: CGPoint(x: 0, y: dayHeaderView.frame.maxY),
                                       size: CGSize(width: bounds.width, height: timelinePagerHeight))
    }
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
  
  public func endEventEditing() {
    timelinePagerView.endEventEditing()
  }

  // MARK: TimelinePagerViewDelegate

  public func timelinePagerDidSelectEventView(_ eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  public func timelinePagerDidLongPressEventView(_ eventView: EventView) {
    delegate?.dayViewDidLongPressEventView(eventView)
  }
  public func timelinePagerDidBeginDragging(timelinePager: TimelinePagerView) {
    delegate?.dayViewDidBeginDragging(dayView: self)
  }
  public func timelinePagerDidTransitionCancel(timelinePager: TimelinePagerView) {
    delegate?.dayViewDidTransitionCancel(dayView: self)
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
  public func timelinePager(timelinePager: TimelinePagerView, didTapTimelineAt date: Date) {
    delegate?.dayView(dayView: self, didTapTimelineAt: date)
  }
  public func timelinePager(timelinePager: TimelinePagerView, didUpdate event: EventDescriptor) {
    delegate?.dayView(dayView: self, didUpdate: event)
  }
}
