import UIKit
import Neon
import DateToolsSwift

public protocol TimelinePagerViewDelegate: AnyObject {
  func timelinePagerDidSelectEventView(_ eventView: EventView)
  func timelinePagerDidLongPressEventView(_ eventView: EventView)
  func timelinePagerDidLongPressTimelineAtHour(_ hour: Int)
  func timelinePager(timelinePager: TimelinePagerView, willMoveTo date: Date)
  func timelinePager(timelinePager: TimelinePagerView, didMoveTo  date: Date)
}

public class TimelinePagerView: UIView {

  public weak var dataSource: EventDataSource?
  public weak var delegate: TimelinePagerViewDelegate?

  public var calendar: Calendar = Calendar.autoupdatingCurrent

  public var timelineScrollOffset: CGPoint {
    // Any view is fine as they are all synchronized
    let offset = (pagingViewController.viewControllers?.first as? TimelineContainerController)?.container.contentOffset
    return offset ?? CGPoint()
  }

  open var autoScrollToFirstEvent = false

  var pagingViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
  var style = TimelineStyle()

  weak var state: DayViewState? {
    willSet(newValue) {
      state?.unsubscribe(client: self)
    }
    didSet {
      state?.subscribe(client: self)
    }
  }

  init(calendar: Calendar) {
    self.calendar = calendar
    super.init(frame: .zero)
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
    let vc = configureTimelineController(date: Date())
    pagingViewController.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    pagingViewController.dataSource = self
    pagingViewController.delegate = self
    addSubview(pagingViewController.view!)
  }

  public func updateStyle(_ newStyle: TimelineStyle) {
    style = newStyle.copy() as! TimelineStyle
    pagingViewController.viewControllers?.forEach({ (timelineContainer) in
      if let controller = timelineContainer as? TimelineContainerController {
        self.updateStyleOfTimelineContainer(controller: controller)
      }
    })
    pagingViewController.view.backgroundColor = style.backgroundColor
  }

  func updateStyleOfTimelineContainer(controller: TimelineContainerController) {
    let container = controller.container
    let timeline = controller.timeline
    timeline.updateStyle(style)
    container.backgroundColor = style.backgroundColor
  }

  public func timelinePanGestureRequire(toFail gesture: UIGestureRecognizer) {
    for controller in pagingViewController.viewControllers ?? [] {
      if let controller = controller as? TimelineContainerController {
        let container = controller.container
        container.panGestureRecognizer.require(toFail: gesture)
      }
    }
  }

  public func scrollTo(hour24: Float) {
    // Any view is fine as they are all synchronized
    if let controller = pagingViewController.viewControllers?.first as? TimelineContainerController {
      controller.container.scrollTo(hour24: hour24)
    }
  }

  func configureTimelineController(date: Date) -> TimelineContainerController {
    let controller = TimelineContainerController()
    updateStyleOfTimelineContainer(controller: controller)
    let timeline = controller.timeline
    timeline.delegate = self
    timeline.eventViewDelegate = self
    timeline.calendar = calendar
    timeline.date = date.dateOnly(calendar: calendar)
    updateTimeline(timeline)
    return controller
  }

  public func reloadData() {
    pagingViewController.children.forEach({ (controller) in
      if let controller = controller as? TimelineContainerController {
        self.updateTimeline(controller.timeline)
      }
    })
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    pagingViewController.view.fillSuperview()
  }

  func updateTimeline(_ timeline: TimelineView) {
    guard let dataSource = dataSource else {return}
    let date = timeline.date.dateOnly(calendar: calendar)
    let events = dataSource.eventsForDate(date)
    let day = TimePeriod(beginning: date,
                         chunk: TimeChunk.dateComponents(days: 1))
    let validEvents = events.filter{$0.datePeriod.overlaps(with: day)}
    timeline.layoutAttributes = validEvents.map(EventLayoutAttributes.init)
  }

  func scrollToFirstEventIfNeeded() {
    if autoScrollToFirstEvent {
      if let controller = pagingViewController.viewControllers?.first as? TimelineContainerController {
        controller.container.scrollToFirstEvent()
      }
    }
  }
}

extension TimelinePagerView: DayViewStateUpdating {
  public func move(from oldDate: Date, to newDate: Date) {
    let oldDate = oldDate.dateOnly(calendar: calendar)
    let newDate = newDate.dateOnly(calendar: calendar)
    let newController = configureTimelineController(date: newDate)

    delegate?.timelinePager(timelinePager: self, willMoveTo: newDate)

    func completionHandler(_ completion: Bool) {
      pagingViewController.viewControllers?.first?.view.setNeedsLayout()
      scrollToFirstEventIfNeeded()
      delegate?.timelinePager(timelinePager: self, willMoveTo: newDate)
    }

    if newDate.isEarlier(than: oldDate) {
      pagingViewController.setViewControllers([newController], direction: .reverse, animated: true, completion: completionHandler(_:))
    } else if newDate.isLater(than: oldDate) {
      pagingViewController.setViewControllers([newController], direction: .forward, animated: true, completion: completionHandler(_:))
    }
  }
}

extension TimelinePagerView: UIPageViewControllerDataSource {
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let containerController = viewController as? TimelineContainerController  else {return nil}
    let previousDate = containerController.timeline.date.add(TimeChunk.dateComponents(days: -1), calendar: calendar)
    let vc = configureTimelineController(date: previousDate)
    let offset = (pageViewController.viewControllers?.first as? TimelineContainerController)?.container.contentOffset
    vc.pendingContentOffset = offset
    return vc
  }

  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let containerController = viewController as? TimelineContainerController  else {return nil}
    let nextDate = containerController.timeline.date.add(TimeChunk.dateComponents(days: 1), calendar: calendar)
    let vc = configureTimelineController(date: nextDate)
    let offset = (pageViewController.viewControllers?.first as? TimelineContainerController)?.container.contentOffset
    vc.pendingContentOffset = offset
    return vc
  }
}

extension TimelinePagerView: UIPageViewControllerDelegate {
  public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else {return}
    if let timelineContainerController = pageViewController.viewControllers?.first as? TimelineContainerController {
      let selectedDate = timelineContainerController.timeline.date
      delegate?.timelinePager(timelinePager: self, willMoveTo: selectedDate)
      state?.client(client: self, didMoveTo: selectedDate)
      scrollToFirstEventIfNeeded()
      delegate?.timelinePager(timelinePager: self, didMoveTo: selectedDate)
    }
  }
}

extension TimelinePagerView: TimelineViewDelegate {
  public func timelineView(_ timelineView: TimelineView, didLongPressAt hour: Int) {
    delegate?.timelinePagerDidLongPressTimelineAtHour(hour)
  }
}

extension TimelinePagerView: EventViewDelegate {
  public func eventViewDidTap(_ eventView: EventView) {
    delegate?.timelinePagerDidSelectEventView(eventView)
  }
  public func eventViewDidLongPress(_ eventview: EventView) {
    delegate?.timelinePagerDidLongPressEventView(eventview)
  }
}
