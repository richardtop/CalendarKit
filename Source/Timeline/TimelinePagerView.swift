import UIKit

public protocol TimelinePagerViewDelegate: AnyObject {
  func timelinePagerDidSelectEventView(_ eventView: EventView)
  func timelinePagerDidLongPressEventView(_ eventView: EventView)
  func timelinePager(timelinePager: TimelinePagerView, didTapTimelineAt date: Date)
  func timelinePagerDidBeginDragging(timelinePager: TimelinePagerView)
  func timelinePagerDidTransitionCancel(timelinePager: TimelinePagerView)
  func timelinePager(timelinePager: TimelinePagerView, willMoveTo date: Date)
  func timelinePager(timelinePager: TimelinePagerView, didMoveTo  date: Date)
  func timelinePager(timelinePager: TimelinePagerView, didLongPressTimelineAt date: Date)

  // Editing
  func timelinePager(timelinePager: TimelinePagerView, didUpdate event: EventDescriptor)
}

public final class TimelinePagerView: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate, DayViewStateUpdating, UIPageViewControllerDataSource, UIPageViewControllerDelegate, TimelineViewDelegate {

  public weak var dataSource: EventDataSource?
  public weak var delegate: TimelinePagerViewDelegate?

  public private(set) var calendar: Calendar = Calendar.autoupdatingCurrent

  public var timelineScrollOffset: CGPoint {
    // Any view is fine as they are all synchronized
    let offset = (currentTimeline)?.container.contentOffset
    return offset ?? CGPoint()
  }
  
  private var currentTimeline: TimelineContainerController? {
    return pagingViewController.viewControllers?.first as? TimelineContainerController
  }

  public var autoScrollToFirstEvent = false

  private var pagingViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
  private var style = TimelineStyle()

  private lazy var panGestureRecoognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(handlePanGesture(_:)))
  
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    if otherGestureRecognizer.view is EventResizeHandleView {
      return false
    }
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

  public weak var state: DayViewState? {
    willSet(newValue) {
      state?.unsubscribe(client: self)
    }
    didSet {
      state?.subscribe(client: self)
    }
  }

  public init(calendar: Calendar) {
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

  private func configure() {
    let vc = configureTimelineController(date: Date())
    pagingViewController.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    pagingViewController.dataSource = self
    pagingViewController.delegate = self
    addSubview(pagingViewController.view!)
    addGestureRecognizer(panGestureRecoognizer)
    panGestureRecoognizer.delegate = self
  }

  public func updateStyle(_ newStyle: TimelineStyle) {
    style = newStyle
    pagingViewController.viewControllers?.forEach({ (timelineContainer) in
      if let controller = timelineContainer as? TimelineContainerController {
        self.updateStyleOfTimelineContainer(controller: controller)
      }
    })
    pagingViewController.view.backgroundColor = style.backgroundColor
  }

  private func updateStyleOfTimelineContainer(controller: TimelineContainerController) {
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

  public func scrollTo(hour24: Float, animated: Bool = true) {
    // Any view is fine as they are all synchronized
    if let controller = currentTimeline {
      controller.container.scrollTo(hour24: hour24, animated: animated)
    }
  }

  private func configureTimelineController(date: Date) -> TimelineContainerController {
    let controller = TimelineContainerController()
    updateStyleOfTimelineContainer(controller: controller)
    let timeline = controller.timeline
    timeline.longPressGestureRecognizer.addTarget(self, action: #selector(timelineDidLongPress(_:)))
    timeline.delegate = self
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
    pagingViewController.view.frame = bounds
  }

  private func updateTimeline(_ timeline: TimelineView) {
    guard let dataSource = dataSource else {return}
    let date = timeline.date.dateOnly(calendar: calendar)
    let events = dataSource.eventsForDate(date)

    let end = calendar.date(byAdding: .day, value: 1, to: date)!
    let day = date ... end
    let validEvents = events.filter{$0.datePeriod.overlaps(day)}
    timeline.layoutAttributes = validEvents.map(EventLayoutAttributes.init)
  }

  public func scrollToFirstEventIfNeeded(animated: Bool) {
    if autoScrollToFirstEvent {
      if let controller = currentTimeline {
        controller.container.scrollToFirstEvent(animated: animated)
      }
    }
  }

  // Event creation prototype
  private var pendingEvent: EventView?
  
  /// Tag of the last used resize handle
  private var resizeHandleTag: Int?

  /// Creates an EventView and places it on the Timeline
  /// - Parameter event: the EventDescriptor based on which an EventView will be placed on the Timeline
  /// - Parameter animated: if true, CalendarKit animates event creation
  public func create(event: EventDescriptor, animated: Bool) {
    let eventView = EventView()
    eventView.updateWithDescriptor(event: event)
    addSubview(eventView)
    // layout algo
    if let currentTimeline = currentTimeline {
      
      for handle in eventView.eventResizeHandles {
        let panGestureRecognizer = handle.panGestureRecognizer
        panGestureRecognizer.addTarget(self, action: #selector(handleResizeHandlePanGesture(_:)))
        panGestureRecognizer.cancelsTouchesInView = true
        
      }
      
      let timeline = currentTimeline.timeline
      let offset = currentTimeline.container.contentOffset.y
      // algo needs to be extracted to a separate object
      let yStart = timeline.dateToY(event.startDate) - offset
      let yEnd = timeline.dateToY(event.endDate) - offset

        
      let rightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
      let x = rightToLeft ? 0 : timeline.style.leadingInset
      let newRect = CGRect(x: x,
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
  
  /// Puts timeline in the editing mode and highlights a single event as being edited.
  /// - Parameter event: the `EventDescriptor` to be edited. An editable copy of the `EventDescriptor` is created by calling `makeEditable()` method on the passed value
  /// - Parameter animated: if true, CalendarKit animates beginning of the editing
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
  
  @objc func handleResizeHandlePanGesture(_ sender: UIPanGestureRecognizer) {
    if let pendingEvent = pendingEvent {
      let newCoord = sender.translation(in: pendingEvent)
      if sender.state == .began {
        prevOffset = newCoord
      }
      guard let tag = sender.view?.tag else {
        return
      }
      resizeHandleTag = tag

      let diff = CGPoint(x: newCoord.x - prevOffset.x,
                         y: newCoord.y - prevOffset.y)
      var suggestedEventFrame = pendingEvent.frame

      if tag == 0 { // Top handle
        suggestedEventFrame.origin.y += diff.y
        suggestedEventFrame.size.height -= diff.y
      } else { // Bottom handle
        suggestedEventFrame.size.height += diff.y
      }
      let minimumMinutesEventDurationWhileEditing = CGFloat(style.minimumEventDurationInMinutesWhileEditing)
      let minimumEventHeight = minimumMinutesEventDurationWhileEditing * style.verticalDiff / 60
      let suggestedEventHeight = suggestedEventFrame.size.height
      
      if suggestedEventHeight > minimumEventHeight {
        pendingEvent.frame = suggestedEventFrame
        prevOffset = newCoord
        accentDateForPendingEvent(eventHeight: tag == 0 ? 0 : suggestedEventHeight)
      }
    }
    
    if sender.state == .ended {
      commitEditing()
    }
  }

  private func accentDateForPendingEvent(eventHeight: CGFloat = 0) {
    if let currentTimeline = currentTimeline {
      let timeline = currentTimeline.timeline
      let converted = timeline.convert(CGPoint.zero, from: pendingEvent)
      let date = timeline.yToDate(converted.y + eventHeight)
      timeline.accentedDate = date
      timeline.setNeedsDisplay()
    }
  }

  private func commitEditing() {
    if let currentTimeline = currentTimeline {
      let timeline = currentTimeline.timeline
      timeline.accentedDate = nil
      setNeedsDisplay()

      // TODO: Animate cancellation

      if let editedEventView = pendingEvent,
        let descriptor = editedEventView.descriptor {
        update(descriptor: descriptor, with: editedEventView)
        
        let ytd = yToDate(y: editedEventView.frame.origin.y,
                          timeline: timeline)
        let snapped = timeline.snappingBehavior.nearestDate(to: ytd)
        let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
        let x = leftToRight ? style.leadingInset : 0
        
        var eventFrame = editedEventView.frame
        eventFrame.origin.x = x
        eventFrame.origin.y = timeline.dateToY(snapped) - currentTimeline.container.contentOffset.y

        if resizeHandleTag == 0 {
          eventFrame.size.height = timeline.dateToY(descriptor.endDate) - timeline.dateToY(snapped)
        } else if resizeHandleTag == 1 {
          let bottomHandleYTD = yToDate(y: editedEventView.frame.origin.y + editedEventView.frame.size.height,
                                        timeline: timeline)
          let bottomHandleSnappedDate = timeline.snappingBehavior.nearestDate(to: bottomHandleYTD)
          eventFrame.size.height = timeline.dateToY(bottomHandleSnappedDate) - timeline.dateToY(snapped)
        }
        
        func animateEventSnap() {
          editedEventView.frame = eventFrame
        }

        func completionHandler(_ completion: Bool) {
          update(descriptor: descriptor, with: editedEventView)
          delegate?.timelinePager(timelinePager: self, didUpdate: descriptor)
        }

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 5,
                       options: [],
                       animations: animateEventSnap,
                       completion: completionHandler(_:))
      }
      
      resizeHandleTag = nil
      prevOffset = .zero
    }
  }

  /// Ends editing mode
  public func endEventEditing() {
    prevOffset = .zero
    pendingEvent?.eventResizeHandles.forEach{$0.panGestureRecognizer.removeTarget(self, action: nil)}
    pendingEvent?.removeFromSuperview()
    pendingEvent = nil
  }

  @objc private func timelineDidLongPress(_ sender: UILongPressGestureRecognizer) {
    if sender.state == .ended {
      commitEditing()
    }
  }
  
  private func yToDate(y: CGFloat, timeline: TimelineView) -> Date {
    let point = CGPoint(x: 0, y: y)
    let converted = convert(point, to: timeline).y
    let date = timeline.yToDate(converted)
    return date
  }

  private func update(descriptor: EventDescriptor, with eventView: EventView) {
    if let currentTimeline = currentTimeline {
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

  // MARK: DayViewStateUpdating

  public func move(from oldDate: Date, to newDate: Date) {
    let oldDate = oldDate.dateOnly(calendar: calendar)
    let newDate = newDate.dateOnly(calendar: calendar)
    let newController = configureTimelineController(date: newDate)

    delegate?.timelinePager(timelinePager: self, willMoveTo: newDate)

    func completionHandler(_ completion: Bool) {
      DispatchQueue.main.async { [self] in
        // Fix for the UIPageViewController issue: https://stackoverflow.com/questions/12939280/uipageviewcontroller-navigates-to-wrong-page-with-scroll-transition-style
        
        let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
        let direction: UIPageViewController.NavigationDirection = leftToRight ? .reverse : .forward
        
        self.pagingViewController.setViewControllers([newController],
                                                      direction: direction,
                                                      animated: false,
                                                      completion: nil)
              
        self.pagingViewController.viewControllers?.first?.view.setNeedsLayout()
        self.scrollToFirstEventIfNeeded(animated: true)
        self.delegate?.timelinePager(timelinePager: self, didMoveTo: newDate)
      }
    }

    if newDate < oldDate {
      let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
      let direction: UIPageViewController.NavigationDirection = leftToRight ? .reverse : .forward
      pagingViewController.setViewControllers([newController],
                                              direction: direction,
                                              animated: true,
                                              completion: completionHandler(_:))
    } else if newDate > oldDate {
      let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
      let direction: UIPageViewController.NavigationDirection = leftToRight ? .forward : .reverse
      pagingViewController.setViewControllers([newController],
                                              direction: direction,
                                              animated: true,
                                              completion: completionHandler(_:))
    }
  }

  // MARK: UIPageViewControllerDataSource

  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let containerController = viewController as? TimelineContainerController  else {return nil}
    let previousDate = calendar.date(byAdding: .day, value: -1, to: containerController.timeline.date)!
    let vc = configureTimelineController(date: previousDate)
    let offset = (pageViewController.viewControllers?.first as? TimelineContainerController)?.container.contentOffset
    vc.pendingContentOffset = offset
    return vc
  }

  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let containerController = viewController as? TimelineContainerController  else {return nil}
    let nextDate = calendar.date(byAdding: .day, value: 1, to: containerController.timeline.date)!
    let vc = configureTimelineController(date: nextDate)
    let offset = (pageViewController.viewControllers?.first as? TimelineContainerController)?.container.contentOffset
    vc.pendingContentOffset = offset
    return vc
  }

  // MARK: UIPageViewControllerDelegate

  public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else {
      delegate?.timelinePagerDidTransitionCancel(timelinePager: self)
      return
    }
    if let timelineContainerController = pageViewController.viewControllers?.first as? TimelineContainerController {
      let selectedDate = timelineContainerController.timeline.date
      delegate?.timelinePager(timelinePager: self, willMoveTo: selectedDate)
      state?.client(client: self, didMoveTo: selectedDate)
      scrollToFirstEventIfNeeded(animated: true)
      delegate?.timelinePager(timelinePager: self, didMoveTo: selectedDate)
    }
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    delegate?.timelinePagerDidBeginDragging(timelinePager: self)
  }

  // MARK: TimelineViewDelegate
  
  public func timelineView(_ timelineView: TimelineView, didTapAt date: Date) {
    delegate?.timelinePager(timelinePager: self, didTapTimelineAt: date)
  }
  
  public func timelineView(_ timelineView: TimelineView, didLongPressAt date: Date) {
    delegate?.timelinePager(timelinePager: self, didLongPressTimelineAt: date)
  }
  
  public func timelineView(_ timelineView: TimelineView, didTap event: EventView) {
    delegate?.timelinePagerDidSelectEventView(event)
  }
  
  public func timelineView(_ timelineView: TimelineView, didLongPress event: EventView) {
    delegate?.timelinePagerDidLongPressEventView(event)
  }
}
