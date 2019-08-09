import UIKit
import Neon
import DateToolsSwift

public protocol TimelinePagerViewDelegate: AnyObject {
  func timelinePagerDidSelectEventView(_ eventView: EventView)
  func timelinePagerDidLongPressEventView(_ eventView: EventView)
  func timelinePagerDidTap(timelinePager: TimelinePagerView)
  func timelinePager(timelinePager: TimelinePagerView, willMoveTo date: Date)
  func timelinePager(timelinePager: TimelinePagerView, didMoveTo  date: Date)
  func timelinePager(timelinePager: TimelinePagerView, didLongPressTimelineAt date: Date)

  // Editing
  func timelinePager(timelinePager: TimelinePagerView, didUpdate event: EventDescriptor)
}

public class TimelinePagerView: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate {

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

  lazy var panGestureRecoognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(handlePanGesture(_:)))
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard gestureRecognizer == panGestureRecoognizer else {
      return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    guard let pendingEvent = pendingEvent else {return true}
    let eventFrame = pendingEvent.frame
    let position = panGestureRecoognizer.location(in: self)
    let contains = eventFrame.contains(position)
    return contains
  }

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
    addGestureRecognizer(panGestureRecoognizer)
    panGestureRecoognizer.delegate = self
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
    timeline.longPressGestureRecognizer.addTarget(self, action: #selector(timelineDidLongPress(_:)))
    timeline.delegate = self
    timeline.eventViewDelegate = self
    timeline.calendar = calendar
    timeline.date = date.dateOnly(calendar: calendar)
    controller.container.delegate = self
    updateTimeline(timeline)
    return controller
  }

  private var initialContentOffset = CGPoint.zero
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    initialContentOffset = scrollView.contentOffset
  }

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offset = scrollView.contentOffset
    let diff = offset.y - initialContentOffset.y
    if let event = pendingEvent {
      var frame = event.frame
      frame.origin.y -= diff
      event.frame = frame
      initialContentOffset = offset
    }
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


  // Event creation prototype
  private var pendingEvent: EventView?

  public func create(event: EventDescriptor, animated: Bool) {
    let eventView = EventView()
    eventView.updateWithDescriptor(event: event)
    addSubview(eventView)
    // layout algo
    if let currentTimeline = pagingViewController.viewControllers?.first as? TimelineContainerController {
      let timeline = currentTimeline.timeline
      let offset = currentTimeline.container.contentOffset.y
      // algo needs to be extracted to a separate object
      let yStart = timeline.dateToY(event.startDate) - offset
      let yEnd = timeline.dateToY(event.endDate) - offset

      let newRect = CGRect(x: timeline.style.leftInset,
                           y: yStart,
                           width: timeline.calendarWidth,
                           height: yEnd - yStart)
      eventView.frame = newRect

      if animated {
        eventView.animateCreation()
      }
    }
    pendingEvent = eventView
    accentDateForPendingEvent()
  }

  public func beginEditing(event: EventDescriptor, animated: Bool = false) {
    if pendingEvent == nil {
      let edited = event.makeEditable()
      create(event: edited, animated: animated)
    }
  }

  private var prevOffset: CGPoint = .zero
  @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
    if let pendingEvent = pendingEvent {
      let newCoord = sender.translation(in: pendingEvent)
      if sender.state == .began {
        prevOffset = newCoord
      }

      let diff = CGPoint(x: newCoord.x - prevOffset.x, y: newCoord.y - prevOffset.y)
      pendingEvent.frame.origin.x += diff.x
      pendingEvent.frame.origin.y += diff.y
      prevOffset = newCoord
      accentDateForPendingEvent()
    }

    if sender.state == .ended {
      commitEditing()
    }
  }

  private func accentDateForPendingEvent() {
    if let currentTimeline = pagingViewController.viewControllers?.first as? TimelineContainerController {
      let timeline = currentTimeline.timeline
      let converted = timeline.convert(CGPoint.zero, from: pendingEvent)
      let date = timeline.yToDate(converted.y)
      timeline.accentedDate = date
      timeline.setNeedsDisplay()
    }
  }

  private func commitEditing() {
    if let currentTimeline = pagingViewController.viewControllers?.first as? TimelineContainerController {
      let timeline = currentTimeline.timeline
      timeline.accentedDate = nil
      setNeedsDisplay()

      // TODO: Animate cancellation

      if let editedEventView = pendingEvent,
        let descriptor = editedEventView.descriptor {

        let startY = timeline.dateToY(descriptor.datePeriod.beginning!)
        let calendarWidth = timeline.calendarWidth
        let x = style.leftInset

        var eventFrame = editedEventView.frame
        eventFrame.origin.x = x

        func animateEventSnap() {
          editedEventView.frame = eventFrame
        }

        func completionHandler(_ completion: Bool) {
          update(descriptor: descriptor, with: editedEventView)
          delegate?.timelinePager(timelinePager: self, didUpdate: descriptor)
        }

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 5,
                       options: [],
                       animations: animateEventSnap,
                       completion: completionHandler(_:))
      }

      prevOffset = .zero
    }
  }

  public func cancelPendingEventCreation() {
    prevOffset = .zero
    pendingEvent?.removeFromSuperview()
    pendingEvent = nil
  }

  @objc private func timelineDidLongPress(_ sender: UILongPressGestureRecognizer) {
    if sender.state == .ended {
      commitEditing()
    }
  }

  private func update(descriptor: EventDescriptor, with eventView: EventView) {
    if let currentTimeline = pagingViewController.viewControllers?.first as? TimelineContainerController {
      let timeline = currentTimeline.timeline
      let eventFrame = eventView.frame
      let converted = convert(eventFrame, to: timeline)
      let beginningY = converted.minY
      let endY = converted.maxY
      let beginning = timeline.yToDate(beginningY)
      let end = timeline.yToDate(endY)
      descriptor.startDate = beginning
      descriptor.endDate = end
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
      delegate?.timelinePager(timelinePager: self, didMoveTo: newDate)
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
  public func timelineViewDidTap(_ timelineView: TimelineView) {
    delegate?.timelinePagerDidTap(timelinePager: self)
  }
  public func timelineView(_ timelineView: TimelineView, didLongPressAt date: Date) {
    delegate?.timelinePager(timelinePager: self, didLongPressTimelineAt: date)
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
