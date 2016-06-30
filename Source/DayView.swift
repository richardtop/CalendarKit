import UIKit
import Neon

protocol DayViewDataSource: class {
  func eventViewsForDate(date: NSDate) -> [EventView]
}

protocol DayViewDelegate: class {
  func dayViewDidSelectEventView(eventview: EventView)
  func dayViewDidLongPressEventView(eventView: EventView)
}

class DayView: UIView {

  weak var dataSource: DayViewDataSource?
  weak var delegate: DayViewDelegate?

  var headerHeight: CGFloat = 88

  let dayHeaderView = DayHeaderView()
  let timelinePager = PagingScrollView<TimelineContainer>()

  var currentDate = NSDate().dateOnly()

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
    for i in -1...1 {
      let timeline = TimelineView(frame: bounds)
      timeline.frame.size.height = timeline.fullHeight
      timeline.date = currentDate.dateByAddingDays(i)

      timeline.label.text = String(i)

      let verticalScrollView = TimelineContainer()
      verticalScrollView.timeline = timeline
      verticalScrollView.addSubview(timeline)
      verticalScrollView.contentSize = timeline.frame.size

      timelinePager.addSubview(verticalScrollView)
      timelinePager.reusableViews.append(verticalScrollView)
    }
    addSubview(timelinePager)

    timelinePager.viewDelegate = self
    let contentWidth = CGFloat(timelinePager.reusableViews.count) * UIScreen.mainScreen().bounds.width
    let size = CGSize(width: contentWidth, height: 50)
    timelinePager.contentSize = size
    timelinePager.contentOffset = CGPoint(x: UIScreen.mainScreen().bounds.width, y: 0)
  }

  override func layoutSubviews() {
    dayHeaderView.anchorAndFillEdge(.Top, xPad: 0, yPad: 0, otherSize: headerHeight)
    timelinePager.alignAndFill(align: .UnderCentered, relativeTo: dayHeaderView, padding: 0)
  }

  func updateTimeline(timeline: TimelineView) {
    guard let dataSource = dataSource else {return}
    let eventViews = dataSource.eventViewsForDate(timeline.date)
//    eventViews.forEach.map{$0.delegate = self}
    timeline.eventViews = eventViews
  }
}

extension DayView: EventViewDelegate {
  func eventViewDidTap(eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  func eventViewDidLongPress(eventview: EventView) {
    delegate?.dayViewDidLongPressEventView(eventview)
  }
}

extension DayView: PagingScrollViewDelegate {
  func updateViewAtIndex(index: Int) {
    let timeline = timelinePager.reusableViews[index].timeline
    let amount = index > 1 ? 1 : -1
    timeline.date = currentDate.dateByAddingDays(amount)
    updateTimeline(timeline)
  }

  func scrollviewDidScrollToViewAtIndex(index: Int) {
    let timeline = timelinePager.reusableViews[index].timeline
    currentDate = timeline.date
    dayHeaderView.selectDate(currentDate)
  }
}

extension DayView: DayHeaderViewDelegate {
  func dateHeaderDateChanged(newDate: NSDate) {
    //TODO: refactor
    if newDate.isEarlierThan(currentDate) {
     let timelineContainer = timelinePager.reusableViews.first!
      timelineContainer.timeline.date = newDate
      updateTimeline(timelineContainer.timeline)
      timelinePager.scrollBackward()

    } else if newDate.isLaterThan(currentDate) {
      let timelineContainer = timelinePager.reusableViews.last!
      timelineContainer.timeline.date = newDate
      updateTimeline(timelineContainer.timeline)
      timelinePager.scrollForward()
    }
  }
}
