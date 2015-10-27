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
  lazy var swipeLabelView: SwipeLabelView = SwipeLabelView(date: self.dateOnlyFromDate(NSDate()))

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func dateOnlyFromDate(date: NSDate) -> NSDate {
    return NSDate(year: date.year(), month: date.month(), day: date.day())
  }

  func configure() {
    [daySymbolsView, pagingScrollView, swipeLabelView].forEach {
        addSubview($0)
    }
    configurePages()
    pagingScrollView.viewDelegate = self
    backgroundColor = UIColor(white: 247/255, alpha: 1)
  }

  func configurePages() {
    for i in 0...2 {
      let daySelector = DaySelector()
      let offset = i - 1
      let date = NSDate().dateByAddingWeeks(offset)

      daySelector.startDate = beginningOfWeek(date)
      pagingScrollView.reusableViews.append(daySelector)
      pagingScrollView.addSubview(daySelector)
      //TODO: Refactor default scroll offset
      pagingScrollView.contentOffset = CGPoint(x: UIScreen.mainScreen().bounds.width, y: 0)
      daySelector.delegate = self
    }
  }

  func selectDate(selectedDate: NSDate) {
    // FIXME: this is a draft. Interface of scrollview should be changed
    let centerDaySelector = pagingScrollView.reusableViews[1] as! DaySelector
    let startDate = dateOnlyFromDate(centerDaySelector.startDate)

    let dateRange = DTTimePeriod(size: .Week, startingAt: startDate)
    if dateRange.containsDate(selectedDate, interval: .Open) {
      let diff = selectedDate.daysFrom(startDate)
      centerDaySelector.selectedIndex = diff
    } else {
      // TODO: Check for the direction of scrolling and reconfigure appropriate DatySelector
    }
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