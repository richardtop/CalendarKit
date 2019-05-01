import UIKit
import DateToolsSwift

public class DayHeaderView: UIView {

  public var daysInWeek = 7

  public var calendar = Calendar.autoupdatingCurrent

  var style = DayHeaderStyle()
  var currentSizeClass = UIUserInterfaceSizeClass.compact

  weak var state: DayViewState? {
    willSet(newValue) {
      state?.unsubscribe(client: self)
    }
    didSet {
      state?.subscribe(client: self)
      swipeLabelView.state = state
    }
  }

  var currentWeekdayIndex = -1

  var daySymbolsViewHeight: CGFloat = 20
  var pagingScrollViewHeight: CGFloat = 40
  var swipeLabelViewHeight: CGFloat = 20

  lazy var daySymbolsView: DaySymbolsView = DaySymbolsView(daysInWeek: self.daysInWeek)
  var pagingViewController = UIPageViewController(transitionStyle: .scroll,
                                                       navigationOrientation: .horizontal,
                                                       options: nil)
  lazy var swipeLabelView: SwipeLabelView = SwipeLabelView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    [daySymbolsView, swipeLabelView].forEach(addSubview)
    backgroundColor = style.backgroundColor
    configurePagingViewController()
  }
  
  func configurePagingViewController() {
    let selectedDate = Date()
    let vc = makeSelectorController(startDate: beginningOfWeek(selectedDate))
    vc.selectedDate = selectedDate
    currentWeekdayIndex = vc.selectedIndex
    pagingViewController.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    pagingViewController.dataSource = self
    pagingViewController.delegate = self
    addSubview(pagingViewController.view!)
  }
  
  func makeSelectorController(startDate: Date) -> DaySelectorController {
    let new = DaySelectorController()
    new.transitionToHorizontalSizeClass(currentSizeClass)
    new.updateStyle(style.daySelector)
    new.startDate = startDate
    new.delegate = self
    return new
  }
  
  func beginningOfWeek(_ date: Date) -> Date {
    return calendar.date(from: DateComponents(calendar: calendar,
                                              weekday: calendar.firstWeekday,
                                              weekOfYear: date.weekOfYear,
                                              yearForWeekOfYear: date.yearForWeekOfYear))!
  }
  
  public func updateStyle(_ newStyle: DayHeaderStyle) {
    style = newStyle.copy() as! DayHeaderStyle
    daySymbolsView.updateStyle(style.daySymbols)
    swipeLabelView.updateStyle(style.swipeLabel)
    (pagingViewController.viewControllers as? [DaySelectorController])?.forEach{$0.updateStyle(newStyle.daySelector)}
    backgroundColor = style.backgroundColor
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    daySymbolsView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: daySymbolsViewHeight)
    pagingViewController.view?.alignAndFillWidth(align: .underCentered, relativeTo: daySymbolsView, padding: 0, height: pagingScrollViewHeight)
    swipeLabelView.anchorAndFillEdge(.bottom, xPad: 0, yPad: 10, otherSize: swipeLabelViewHeight)
  }

  public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
    currentSizeClass = sizeClass
    daySymbolsView.isHidden = sizeClass == .regular
    (pagingViewController.children as? [DaySelectorController])?.forEach{$0.transitionToHorizontalSizeClass(sizeClass)}
  }
}

extension DayHeaderView: DaySelectorDelegate {
  func dateSelectorDidSelectDate(_ date: Date) {
    state?.move(to: date)
  }
}

extension DayHeaderView: DayViewStateUpdating {
  public func move(from oldDate: Date, to newDate: Date) {
    let newDate = newDate.dateOnly()
    
    let centerView = pagingViewController.viewControllers![0] as! DaySelectorController
    let startDate = centerView.startDate.dateOnly()
    
    let daysFrom = newDate.days(from: startDate, calendar: calendar)
    let newStartDate = beginningOfWeek(newDate)

    let new = makeSelectorController(startDate: newStartDate)
    
    if daysFrom < 0 {
      currentWeekdayIndex = abs(daysInWeek + daysFrom % daysInWeek) % daysInWeek
      new.selectedIndex = currentWeekdayIndex
      pagingViewController.setViewControllers([new], direction: .reverse, animated: true, completion: nil)
    } else if daysFrom > daysInWeek - 1 {
      currentWeekdayIndex = daysFrom % daysInWeek
      new.selectedIndex = currentWeekdayIndex
      pagingViewController.setViewControllers([new], direction: .forward, animated: true, completion: nil)
    } else {
      currentWeekdayIndex = daysFrom
      centerView.selectedDate = newDate
      centerView.selectedIndex = currentWeekdayIndex
    }
  }
}

extension DayHeaderView: UIPageViewControllerDataSource {
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if let selector = viewController as? DaySelectorController {
      let previousDate = selector.startDate.add(TimeChunk.dateComponents(weeks: -1))
      return makeSelectorController(startDate: previousDate)
    }
    return nil
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if let selector = viewController as? DaySelectorController {
      let nextDate = selector.startDate.add(TimeChunk.dateComponents(weeks: 1))
      return makeSelectorController(startDate: nextDate)
    }
    return nil
  }
}

extension DayHeaderView: UIPageViewControllerDelegate {
  public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else {return}
    if let selector = pageViewController.viewControllers?.first as? DaySelectorController {
      selector.selectedIndex = currentWeekdayIndex
      if let selectedDate = selector.selectedDate {
        state?.client(client: self, didMoveTo: selectedDate)
      }
    }
    // Deselect all the views but the currently visible one
    (previousViewControllers as? [DaySelectorController])?.forEach{$0.selectedIndex = -1}
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    (pendingViewControllers as? [DaySelectorController])?.forEach{$0.updateStyle(style.daySelector)}
  }
}
