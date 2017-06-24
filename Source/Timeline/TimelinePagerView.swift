import UIKit
import Neon
import DateToolsSwift

public protocol TimelinePagerViewDelegate: class {
  func timelinePagerDidSelectEventView(_ eventView: EventView)
  func timelinePagerDidLongPressEventView(_ eventView: EventView)
  func timelinePagerDidLongPressTimelineAtHour(_ hour: Int)
  func timelinePager(timelinePager: TimelinePagerView, willMoveTo date: Date)
  func timelinePager(timelinePager: TimelinePagerView, didMoveTo  date: Date)
}

public class TimelinePagerView: UIView {

  public weak var dataSource: EventDataSource?
  public weak var delegate: TimelinePagerViewDelegate?

  public var timelineScrollOffset: CGPoint {
    // Any view is fine as they are all synchronized
    return timelinePager.reusableViews.first?.contentOffset ?? CGPoint()
  }

  open var autoScrollToFirstEvent = false

  let timelinePager = PagingScrollView<TimelineContainer>()
  var timelineSynchronizer: ScrollSynchronizer?

  var currentDate = Date().dateOnly()

  var style = TimelineStyle()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    configureTimelinePager()
  }

  public func updateStyle(_ newStyle: TimelineStyle) {
    style = newStyle.copy() as! TimelineStyle
    timelinePager.reusableViews.forEach{ timelineContainer in
      timelineContainer.timeline.updateStyle(style)
      timelineContainer.backgroundColor = style.backgroundColor
    }
  }

  public func changeCurrentDate(to newDate: Date) {
    let newDate = newDate.dateOnly()
    if newDate.isEarlier(than: currentDate) {
      var timelineDate = newDate
      for (index, timelineContainer) in timelinePager.reusableViews.enumerated() {
        timelineContainer.timeline.date = timelineDate
        timelineDate = timelineDate.add(TimeChunk.dateComponents(days: 1))
        if index == 0 {
          updateTimeline(timelineContainer.timeline)
        }
      }
      timelinePager.scrollBackward()
    } else if newDate.isLater(than: currentDate) {
      var timelineDate = newDate
      for (index, timelineContainer) in timelinePager.reusableViews.reversed().enumerated() {
        timelineContainer.timeline.date = timelineDate
        timelineDate = timelineDate.subtract(TimeChunk.dateComponents(days: 1))
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

  public func scrollTo(hour24: Float) {
    // Any view is fine as they are all synchronized
    timelinePager.reusableViews.first?.scrollTo(hour24: hour24)
  }

  func configureTimelinePager() {
    var verticalScrollViews = [TimelineContainer]()
    for i in -1...1 {
      let timeline = TimelineView(frame: bounds)
      timeline.delegate = self
      timeline.eventViewDelegate = self
      timeline.frame.size.height = timeline.fullHeight
      timeline.date = currentDate.add(TimeChunk.dateComponents(days: i))

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
    timelinePager.fillSuperview()
  }

  func updateTimeline(_ timeline: TimelineView) {
    guard let dataSource = dataSource else {return}
    let date = timeline.date.dateOnly()
    let events = dataSource.eventsForDate(date)
    let day = TimePeriod(beginning: date,
                         chunk: TimeChunk.dateComponents(days: 1))
    let validEvents = events.filter{$0.datePeriod.overlaps(with: day)}
    timeline.eventDescriptors = validEvents
  }
}

extension TimelinePagerView: PagingScrollViewDelegate {
  func updateViewAtIndex(_ index: Int) {
    let timeline = timelinePager.reusableViews[index].timeline
    let amount = index > 1 ? 1 : -1
    timeline?.date = currentDate.add(TimeChunk.dateComponents(days: amount))
    updateTimeline(timeline!)
  }

  func scrollviewDidScrollToViewAtIndex(_ index: Int) {
    let nextDate = timelinePager.reusableViews[index].timeline.date
    delegate?.timelinePager(timelinePager: self, willMoveTo: nextDate)
    currentDate = nextDate
    scrollToFirstEventIfNeeded()
    delegate?.timelinePager(timelinePager: self, didMoveTo: nextDate)
  }

  func scrollToFirstEventIfNeeded() {
    if autoScrollToFirstEvent {
      let index = Int(timelinePager.currentScrollViewPage)
      timelinePager.reusableViews[index].scrollToFirstEvent()
    }
  }
}

extension TimelinePagerView: TimelineViewDelegate {
  func timelineView(_ timelineView: TimelineView, didLongPressAt hour: Int) {
    delegate?.timelinePagerDidLongPressTimelineAtHour(hour)
  }
}

extension TimelinePagerView: EventViewDelegate {
  func eventViewDidTap(_ eventView: EventView) {
    delegate?.timelinePagerDidSelectEventView(eventView)
  }
  func eventViewDidLongPress(_ eventview: EventView) {
    delegate?.timelinePagerDidLongPressEventView(eventview)
  }
}
