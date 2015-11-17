import UIKit
import DateTools

protocol DayHeaderViewDelegate: class {
  func dateHeaderDateChanged(newDate: NSDate)
}

class DayHeaderView: UIView {

  weak var delegate: DayHeaderViewDelegate?

  var daysInWeek = 7

  var calendar = NSCalendar.autoupdatingCurrentCalendar()

  var currentWeekdayIndex = -1
  var currentDate = NSDate().dateOnly()

  var daySymbolsViewHeight: CGFloat = 20
  var pagingScrollViewHeight: CGFloat = 40
  var swipeLabelViewHeight: CGFloat = 20

  lazy var daySymbolsView: DaySymbolsView = DaySymbolsView(daysInWeek: self.daysInWeek)
  let pagingScrollView = PagingScrollView<DaySelector>()
  lazy var swipeLabelView: SwipeLabelView = SwipeLabelView(date: NSDate().dateOnly())

  init(selectedDate: NSDate) {
    self.currentDate = selectedDate
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
      let daySelector = DaySelector(daysInWeek: daysInWeek)
      let date = selectedDate.dateByAddingWeeks(i)

      daySelector.startDate = beginningOfWeek(date)
      pagingScrollView.reusableViews.append(daySelector)
      pagingScrollView.addSubview(daySelector)
      //TODO: Refactor default scroll offset
      pagingScrollView.contentOffset = CGPoint(x: UIScreen.mainScreen().bounds.width, y: 0)
      daySelector.delegate = self
    }
    let centerDaySelector = pagingScrollView.reusableViews[1]
    centerDaySelector.selectedDate = selectedDate
  }

  func beginningOfWeek(date: NSDate) -> NSDate {
    let components = calendar.components([.Year, .Month, .Day, .TimeZone, .Weekday], fromDate: date)
    let offset = components.weekday - calendar.firstWeekday
    components.day = components.day - offset

    return calendar.dateFromComponents(components)!
  }

  func selectDate(selectedDate: NSDate) {
    let centerDaySelector = pagingScrollView.reusableViews[1]
    let startDate = centerDaySelector.startDate.dateOnly()

    let daysFrom = selectedDate.daysFrom(startDate, calendar: calendar)
    print("Days From: \(daysFrom)")

    if daysFrom < 0 {
      print("isEarlierThan")
      pagingScrollView.scrollBackward()
      currentWeekdayIndex = daysInWeek - 1
    } else if daysFrom > daysInWeek - 1 {
      print("isLaterThan")
      pagingScrollView.scrollForward()
      currentWeekdayIndex = 0
    } else {
      print("containsDate")
      centerDaySelector.selectedDate = selectedDate
    }

    swipeLabelView.date = selectedDate
    currentDate = selectedDate
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
    currentDate = date
    currentWeekdayIndex = index
    swipeLabelView.date = date
    delegate?.dateHeaderDateChanged(date)
  }
}

extension DayHeaderView: PagingScrollViewDelegate {

  func updateViewAtIndex(index: Int) {
    let viewToUpdate = pagingScrollView.reusableViews[index]
    let weeksToAdd = index > 1 ? 3 : -3
    viewToUpdate.startDate = viewToUpdate.startDate.dateByAddingWeeks(weeksToAdd)
  }

  func scrollviewDidScrollToViewAtIndex(index: Int) {
    let activeView = pagingScrollView.reusableViews[index]
    activeView.selectedIndex = currentWeekdayIndex
    swipeLabelView.date = activeView.selectedDate!
    delegate?.dateHeaderDateChanged(activeView.selectedDate!)
  }
}
