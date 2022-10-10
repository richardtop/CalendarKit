import UIKit

public protocol DayViewDelegate: AnyObject {
  func dayViewDidSelectEventView(_ eventView: AppointmentView)
  func dayViewDidLongPressEventView(_ eventView: AppointmentView)
  func dayView(dayView: DayView, didTapTimelineAt date: Date)
  func dayView(dayView: DayView, didLongPressTimelineAt date: Date)
  func dayViewDidBeginDragging(dayView: DayView)
  func dayViewDidTransitionCancel(dayView: DayView)
  func dayView(dayView: DayView, willMoveTo date: Date)
  func dayView(dayView: DayView, didMoveTo  date: Date)
  func dayView(dayView: DayView, didUpdate event: EventDescriptor)
    func didTapOnDate(date: Date)
    func didMoveHeaderViewToDate(date: Date)
}

public enum CalendarMode {
    case agenda
    case day
}

public class DayView: UIView, TimelinePagerViewDelegate, DayHeaderViewDelegate {
  public weak var dataSource: EventDataSource? {
    get {
      timelinePagerView.dataSource
    }
    set(value) {
      timelinePagerView.dataSource = value
    }
  }

  public weak var delegate: DayViewDelegate?
    
    public var calendarMode: CalendarMode? {
        didSet {
            switchModeTo(calendarMode: calendarMode!)
        }
    }

  /// Hides or shows header view
  public var isHeaderViewVisible = true {
    didSet {
      headerHeight = isHeaderViewVisible ? DayView.headerVisibleHeight : 0
      dayHeaderView.isHidden = !isHeaderViewVisible
      setNeedsLayout()
      configureLayout()
    }
  }
    
    public var horizontalSpacing: CGFloat = 0 {
        didSet {
            layoutTableView()
            layoutTimelinePagerView()
            switchModeTo(calendarMode: calendarMode ?? .agenda)
        }
    }

  public var timelineScrollOffset: CGPoint {
    timelinePagerView.timelineScrollOffset
  }
    
    var agendaHeightConstraint: NSLayoutConstraint!
    var dayHeightConstraint: NSLayoutConstraint!
    

  private static let headerVisibleHeight: CGFloat = 68 // swipe view height 20
  public var headerHeight: CGFloat = headerVisibleHeight

  public var autoScrollToFirstEvent: Bool {
    get {
      timelinePagerView.autoScrollToFirstEvent
    }
    set (value) {
      timelinePagerView.autoScrollToFirstEvent = value
    }
  }

  public let dayHeaderView: DayHeaderView
  public let timelinePagerView: TimelinePagerView
    public var tableView: UITableView? {
        didSet {
            addTableView()
        }
    }

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
    
    private func addTableView() {
        guard let tableView = tableView else { return }
        addSubview(tableView)
    }

  private func configure() {
    addSubview(timelinePagerView)
    addSubview(dayHeaderView)
            
      agendaHeightConstraint = dayHeaderView.heightAnchor.constraint(equalToConstant: 68)
      dayHeightConstraint = dayHeaderView.heightAnchor.constraint(equalToConstant: 98)
      
    configureLayout()
    timelinePagerView.delegate = self
      dayHeaderView.delegate = self

    if state == nil {
      let newState = DayViewState(date: Date(), calendar: calendar)
      newState.move(to: Date())
      state = newState
    }
      
      if calendarMode == nil {
          switchModeTo(calendarMode: .agenda)
      }
  }
  
    private func switchModeTo(calendarMode: CalendarMode) {
        dayHeaderView.switchModeTo(calendarMode: calendarMode)
        switch calendarMode {
        case .agenda:
            tableView?.isHidden = false
            timelinePagerView.isHidden = true
            NSLayoutConstraint.deactivate([dayHeightConstraint])
            NSLayoutConstraint.activate([agendaHeightConstraint])
        case .day:
            tableView?.isHidden = true
            timelinePagerView.isHidden = false
            NSLayoutConstraint.deactivate([agendaHeightConstraint])
            NSLayoutConstraint.activate([dayHeightConstraint])
        }
    }
    
    private func configureLayout() {
        dayHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dayHeaderView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            dayHeaderView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            dayHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            agendaHeightConstraint
        ])
    }
    
    private func layoutTableView() {
        guard let tableView = tableView else { return }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: dayHeaderView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: horizontalSpacing),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -horizontalSpacing),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func layoutTimelinePagerView() {
        timelinePagerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timelinePagerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: horizontalSpacing),
            timelinePagerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -horizontalSpacing),
            timelinePagerView.topAnchor.constraint(equalTo: dayHeaderView.bottomAnchor),
            timelinePagerView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
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

  public func timelinePagerDidSelectEventView(_ eventView: AppointmentView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  public func timelinePagerDidLongPressEventView(_ eventView: AppointmentView) {
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
    
    // MARK: - DayViewDelegate
    public func didTapOpDate(date: Date) {
        delegate?.didTapOnDate(date: date)
    }
    
    public func didMoveHeaderViewToDate(date: Date) {
        delegate?.didMoveHeaderViewToDate(date: date)
    }
}
