import UIKit
import Neon
import DateTools

protocol DayViewDataSource: class {
  func eventViewsForDate(_ date: Date) -> [EventView]
}

protocol DayViewDelegate: class {
  func dayViewDidSelectEventView(_ eventview: EventView)
  func dayViewDidLongPressEventView(_ eventView: EventView)
}

class DayView: UIView {

  weak var dataSource: DayViewDataSource?
  weak var delegate: DayViewDelegate?

  var headerHeight: CGFloat = 88

  let dayHeaderView = DayHeaderView()
  let timelinePager = PagingScrollView<TimelineContainer>()
  var timelineSynchronizer: ScrollSynchronizer?

  var currentDate = Date().dateOnly()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    configureTimelinePager()
    dayHeaderView.delegate = self
    addSubview(dayHeaderView)
  }

  func configureTimelinePager() {
    var verticalScrollViews = [TimelineContainer]()
    for i in -1...1 {
      let timeline = TimelineView(frame: bounds)
      timeline.frame.size.height = timeline.fullHeight
      timeline.date = currentDate.add(TimeChunk(seconds: 0, minutes: 0, hours: 0, days: i, weeks: 0, months: 0, years: 0))

      timeline.label.text = String(i)

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
    let contentWidth = CGFloat(timelinePager.reusableViews.count) * UIScreen.main.bounds.width
    let size = CGSize(width: contentWidth, height: 50)
    timelinePager.contentSize = size
    timelinePager.contentOffset = CGPoint(x: UIScreen.main.bounds.width, y: 0)
  }

  override func layoutSubviews() {
    dayHeaderView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: headerHeight)
    timelinePager.alignAndFill(align: .underCentered, relativeTo: dayHeaderView, padding: 0)
  }

  func updateTimeline(_ timeline: TimelineView) {
    guard let dataSource = dataSource else {return}
    let eventViews = dataSource.eventViewsForDate(timeline.date)
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
    timeline?.date = currentDate.add(TimeChunk(seconds: 0, minutes: 0, hours: 0, days: amount, weeks: 0, months: 0, years: 0))
    updateTimeline(timeline!)
  }

  func scrollviewDidScrollToViewAtIndex(_ index: Int) {
    let timeline = timelinePager.reusableViews[index].timeline
    currentDate = timeline!.date
    dayHeaderView.selectDate(currentDate)
  }
}

extension DayView: DayHeaderViewDelegate {
  func dateHeaderDateChanged(_ newDate: Date) {
    //TODO: refactor
    if newDate.isEarlier(than: currentDate) {
     let timelineContainer = timelinePager.reusableViews.first!
      timelineContainer.timeline.date = newDate
      updateTimeline(timelineContainer.timeline)
      timelinePager.scrollBackward()

    } else if newDate.isLater(than: currentDate) {
      let timelineContainer = timelinePager.reusableViews.last!
      timelineContainer.timeline.date = newDate
      updateTimeline(timelineContainer.timeline)
      timelinePager.scrollForward()
    }
  }
}
