import UIKit
import DateTools

protocol DayHeaderViewDelegate: class {
  func dateHeaderDateChanged(newDate: NSDate)
}

class DayHeaderView: UIView {

  weak var delegate: DayHeaderViewDelegate?

  var calendar = NSCalendar.autoupdatingCurrentCalendar()

  var currentWeekdayIndex = -1

  var daySymbolsViewHeight: CGFloat = 20
  var pagingScrollViewHeight: CGFloat = 40
  var swipeLabelViewHeight: CGFloat = 20

  let daySymbolsView = DaySymbolsView()
  let pagingScrollView = PagingScrollView()
  lazy var swipeLabelView: SwipeLabelView = SwipeLabelView(date: NSDate().dateOnly())

  init(selectedDate: NSDate) {
    super.init(frame: CGRect.zero)
    configure()
    configurePages(selectedDate)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
    configurePages()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
    configurePages()
  }

  func configure() {
    [daySymbolsView, pagingScrollView, swipeLabelView].forEach {
        addSubview($0)
    }
    pagingScrollView.viewDelegate = self
    backgroundColor = UIColor(white: 247/255, alpha: 1)
  }

  func configurePages(selectedDate: NSDate = NSDate()) {
    for i in -1...1 {
      let daySelector = DaySelector()
      let date = selectedDate.dateByAddingWeeks(i)

      daySelector.startDate = beginningOfWeek(date)
      pagingScrollView.reusableViews.append(daySelector)
      pagingScrollView.addSubview(daySelector)
      //TODO: Refactor default scroll offset
      pagingScrollView.contentOffset = CGPoint(x: UIScreen.mainScreen().bounds.width, y: 0)
      daySelector.delegate = self
    }
    let centerDaySelector = pagingScrollView.reusableViews[1] as! DaySelector
    centerDaySelector.selectedDate = selectedDate
  }

  func selectDate(selectedDate: NSDate) {
    let centerDaySelector = pagingScrollView.reusableViews[1] as! DaySelector
    let startDate = centerDaySelector.startDate.dateOnly()

    let currentWeek = DTTimePeriod(size: .Week, startingAt: startDate)

    if currentWeek.containsDate(selectedDate, interval: .Open) {
      centerDaySelector.selectedDate = selectedDate//.daysFrom(startDate)
    } else if selectedDate.isEarlierThan(currentWeek.StartDate) {
      currentWeekdayIndex = 6
      pagingScrollView.scrollBackward()

    } else if selectedDate.isLaterThan(currentWeek.EndDate) {
      currentWeekdayIndex = 0
      pagingScrollView.scrollForward()
    }
    swipeLabelView.date = selectedDate
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    pagingScrollView.contentSize = CGSize(width: bounds.size.width * CGFloat(pagingScrollView.reusableViews.count), height: 0)

    daySymbolsView.anchorAndFillEdge(.Top, xPad: 0, yPad: 0, otherSize: daySymbolsViewHeight)
    pagingScrollView.alignAndFillWidth(align: .UnderCentered, relativeTo: daySymbolsView, padding: 0, height: pagingScrollViewHeight)
    swipeLabelView.anchorAndFillEdge(.Bottom, xPad: 0, yPad: 10, otherSize: swipeLabelViewHeight)
  }
}

extension DayHeaderView: DaySelectorDelegate {
  func dateSelectorDidSelectDate(date: NSDate, index: Int) {
    currentWeekdayIndex = index
    swipeLabelView.date = date
    delegate?.dateHeaderDateChanged(date)
  }

  func beginningOfWeek(date: NSDate) -> NSDate {
    let components = calendar.components([.Year, .Month, .Day, .TimeZone, .Weekday], fromDate: date)
    let offset = components.weekday - calendar.firstWeekday
    components.day = components.day - offset

    return calendar.dateFromComponents(components)!
  }
}

extension DayHeaderView: PagingScrollViewDelegate {
  func viewRequiresUpdate(view: UIView, scrollDirection: ScrollDirection) {
    let viewToUpdate = view as! DaySelector
    let weeksToAdd = scrollDirection == .Forward ? 3 : -3
    viewToUpdate.startDate = viewToUpdate.startDate.dateByAddingWeeks(weeksToAdd)
  }

  func scrollviewDidScrollToView(view: UIView) {
    let activeView = view as! DaySelector
    activeView.selectedIndex = currentWeekdayIndex
    swipeLabelView.date = activeView.selectedDate!
    delegate?.dateHeaderDateChanged(activeView.selectedDate!
    )
  }
}