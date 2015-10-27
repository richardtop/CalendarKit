import UIKit
import Neon

protocol DayViewDataSource: class {
  func eventViewsForDate(date: NSDate) -> [EventView]
}

class DayView: UIView {

  weak var dataSource: DayViewDataSource?

  var headerHeight: CGFloat = 88

  let dayHeaderView = DayHeaderView()
  let timelinePager = PagingScrollView()

  var currentDate = NSDate()

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
    for i in 0...2 {
      let timeline = TimelineView(frame: bounds)
      timeline.frame.size.height = timeline.fullHeight

      let verticalScrollView = TimelineContainer()
      verticalScrollView.timeline = timeline
      verticalScrollView.addSubview(timeline)
      verticalScrollView.contentSize = timeline.frame.size

      timelinePager.addSubview(verticalScrollView)
      timelinePager.reusableViews.append(verticalScrollView)
    }
    addSubview(timelinePager)
    timelinePager.viewDelegate = self
  }

  override func layoutSubviews() {
    let contentWidth = CGFloat(timelinePager.reusableViews.count) * bounds.size.width
    let size = CGSize(width: contentWidth, height: 0)
    timelinePager.contentSize = size

    dayHeaderView.anchorAndFillEdge(.Top, xPad: 0, yPad: 0, otherSize: headerHeight)
    timelinePager.alignAndFill(align: .UnderCentered, relativeTo: dayHeaderView, padding: 0)
  }
}

extension DayView: PagingScrollViewDelegate {
  func viewRequiresUpdate(view: UIView, scrollDirection: ScrollDirection) {
    let amount = scrollDirection == .Forward ? 1 : -1
    let timeline = (view as! TimelineContainer).timeline
    timeline.date = currentDate.dateByAddingDays(amount)
    if let dataSource = dataSource {
      timeline.eventViews = dataSource.eventViewsForDate(timeline.date)
    }
  }

  func scrollviewDidScrollToView(view: UIView) {
    let timeline = (view as! TimelineContainer).timeline
    currentDate = timeline.date
    dayHeaderView.selectDate(currentDate)
  }
}

extension DayView: DayHeaderViewDelegate {
  func dateHeaderDateChanged(newDate: NSDate) {
    //TODO: refactor
    if newDate.isEarlierThan(currentDate) {
     let timelineContainer = timelinePager.reusableViews.first! as! TimelineContainer
      timelineContainer.timeline.date = newDate
      timelinePager.scrollBackward()
    } else if newDate.isLaterThan(currentDate) {
      let timelineContainer = timelinePager.reusableViews.last! as! TimelineContainer
      timelineContainer.timeline.date = newDate
      timelinePager.scrollForward()
    }
    currentDate = newDate
  }
}
