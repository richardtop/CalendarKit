import UIKit
import Neon
import DateToolsSwift

public protocol DayViewDataSource: class {
  func eventViewsForDate(_ date: Date) -> [EventView]
}

public protocol DayViewDelegate: class {
  func dayViewDidSelectEventView(_ eventview: EventView)
  func dayViewDidLongPressEventView(_ eventView: EventView)
  func dayViewDidLongPressTimelineAtHour(_ hour: Int)
  func dayView(dayView: DayView, willMoveTo date: Date)
  func dayView(dayView: DayView, didMoveTo  date: Date)
}

public protocol DayHeaderProtocol {
  var delegate: DayHeaderViewDelegate? {get set}
  func selectDate(_ selectedDate: Date)
}

  /// Component used only as initialization parameter to enforce both view & controller
public struct DayHeaderComponent {
  let view: UIView
  let controller: DayHeaderProtocol & DayHeaderStyleProtocol
}

public class DayView: UIView {

  /// Hides or shows header view
  public var isHeaderViewVisible = true {
    didSet {
      headerHeight = isHeaderViewVisible ? DayView.headerVisibleHeight : 0
      dayHeaderView.isHidden = !isHeaderViewVisible
      dayHeaderController.delegate = isHeaderViewVisible ? self : nil
      setNeedsLayout()
    }
  }
  public var timelineScrollOffset: CGPoint {
    // Any view is fine as they are all synchronized
    return timelinePager.reusableViews.first?.contentOffset ?? CGPoint()
  }
  
  public weak var dataSource: DayViewDataSource?
  public weak var delegate: DayViewDelegate?

  static let headerVisibleHeight: CGFloat = 88
  var headerHeight: CGFloat = headerVisibleHeight

  var dayHeaderView: UIView
  var dayHeaderController: DayHeaderProtocol & DayHeaderStyleProtocol

  let timelinePager = PagingScrollView<TimelineContainer>()
  var timelineSynchronizer: ScrollSynchronizer?

  var currentDate = Date().dateOnly()

  var style = CalendarStyle()

  public init(headerComponent: DayHeaderComponent? = nil) {
    if let headerComponent = headerComponent {
      dayHeaderView = headerComponent.view
      dayHeaderController = headerComponent.controller
    } else {
      let defaultHeader = DayHeaderView()
      dayHeaderView = defaultHeader
      dayHeaderController = defaultHeader
    }
    super.init(frame: .zero)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    let defaultHeader = DayHeaderView()
    dayHeaderView = defaultHeader
    dayHeaderController = defaultHeader
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    configureTimelinePager()
    dayHeaderController.delegate = self
    addSubview(dayHeaderView)
  }

  public func updateStyle(_ newStyle: CalendarStyle) {
    style = newStyle.copy() as! CalendarStyle
    dayHeaderController.updateStyle(style.header)
    timelinePager.reusableViews.forEach{ timelineContainer in
      timelineContainer.timeline.updateStyle(style.timeline)
      timelineContainer.backgroundColor = style.timeline.backgroundColor
    }
  }

  public func changeCurrentDate(to newDate: Date) {
    let newDate = newDate.dateOnly()
    if newDate.isEarlier(than: currentDate) {
      var timelineDate = newDate
      for (index, timelineContainer) in timelinePager.reusableViews.enumerated() {
        timelineContainer.timeline.date = timelineDate
        timelineDate = timelineDate.add(TimeChunk(seconds: 0, minutes: 0, hours: 0, days: 1, weeks: 0, months: 0, years: 0))
        if index == 0 {
          updateTimeline(timelineContainer.timeline)
        }
      }
      timelinePager.scrollBackward()
    } else if newDate.isLater(than: currentDate) {
      var timelineDate = newDate
      for (index, timelineContainer) in timelinePager.reusableViews.reversed().enumerated() {
        timelineContainer.timeline.date = timelineDate
        timelineDate = timelineDate.subtract(TimeChunk(seconds: 0, minutes: 0, hours: 0, days: 1, weeks: 0, months: 0, years: 0))
        if index == 0 {
          updateTimeline(timelineContainer.timeline)
        }
      }
      timelinePager.scrollForward()
    }
    currentDate = newDate
  }
  
  public func timelinePanGestureRequire(toFail gesture: UIGestureRecognizer) {
    for timelineContainer in timelinePager.reusableViews {
      timelineContainer.panGestureRecognizer.require(toFail: gesture)
    }
  }

  func configureTimelinePager() {
    var verticalScrollViews = [TimelineContainer]()
    for i in -1...1 {
      let timeline = TimelineView(frame: bounds)
      timeline.delegate = self
      timeline.frame.size.height = timeline.fullHeight
      timeline.date = currentDate.add(TimeChunk(seconds: 0,
                                                minutes: 0,
                                                hours: 0,
                                                days: i,
                                                weeks: 0,
                                                months: 0,
                                                years: 0))

      let verticalScrollView = TimelineContainer()
      verticalScrollView.timeline = timeline
      verticalScrollView.addSubview(timeline)
      verticalScrollView.contentSize = timeline.frame.size

      timelinePager.addSubview(verticalScrollView)
      timelinePager.reusableViews.append(verticalScrollView)
      verticalScrollViews.append(verticalScrollView)
    }
    timelineSynchronizer = ScrollSynchronizer(views: verticalScrollViews)
    addSubview(timelinePager)

    timelinePager.viewDelegate = self
  }

  public func reloadData() {
    timelinePager.reusableViews.forEach{self.updateTimeline($0.timeline)}
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    let contentWidth = CGFloat(timelinePager.reusableViews.count) * bounds.width
    let size = CGSize(width: contentWidth, height: 50)
    timelinePager.contentSize = size
    timelinePager.contentOffset = CGPoint(x: bounds.width, y: 0)

    dayHeaderView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: headerHeight)
    timelinePager.alignAndFill(align: .underCentered, relativeTo: dayHeaderView, padding: 0)
  }

  func updateTimeline(_ timeline: TimelineView) {
    guard let dataSource = dataSource else {return}
    let eventViews = dataSource.eventViewsForDate(timeline.date)
    eventViews.forEach{$0.delegate = self}
    timeline.eventViews = eventViews
  }
}

extension DayView: EventViewDelegate {
  func eventViewDidTap(_ eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  func eventViewDidLongPress(_ eventview: EventView) {
    delegate?.dayViewDidLongPressEventView(eventview)
  }
}

extension DayView: PagingScrollViewDelegate {
  func updateViewAtIndex(_ index: Int) {
    let timeline = timelinePager.reusableViews[index].timeline
    let amount = index > 1 ? 1 : -1
    timeline?.date = currentDate.add(TimeChunk(seconds: 0,
                                               minutes: 0,
                                               hours: 0,
                                               days: amount,
                                               weeks: 0,
                                               months: 0,
                                               years: 0))
    updateTimeline(timeline!)
  }

  func scrollviewDidScrollToViewAtIndex(_ index: Int) {
    let nextDate = timelinePager.reusableViews[index].timeline.date
    delegate?.dayView(dayView: self, willMoveTo: nextDate)
    currentDate = nextDate
    dayHeaderController.selectDate(currentDate)
    delegate?.dayView(dayView: self, didMoveTo: currentDate)
  }
}

extension DayView: DayHeaderViewDelegate {
  public func dateHeaderDateChanged(_ newDate: Date) {
    changeCurrentDate(to: newDate)
  }
}

extension DayView: TimelineViewDelegate {
  func timelineView(_ timelineView: TimelineView, didLongPressAt hour: Int) {
    delegate?.dayViewDidLongPressTimelineAtHour(hour)
  }
}
