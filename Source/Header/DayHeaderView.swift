import UIKit
import DateToolsSwift

public protocol DayHeaderViewDelegate: class {
  func dateHeaderDateChanged(_ newDate: Date)
}

public class DayHeaderView: UIView {

  public weak var delegate: DayHeaderViewDelegate?

  public var daysInWeek = 7

  public var calendar = Calendar.autoupdatingCurrent

  var style = DayHeaderStyle()

  var currentWeekdayIndex = -1
  var currentDate = Date().dateOnly()

  var daySymbolsViewHeight: CGFloat = 20
  var pagingScrollViewHeight: CGFloat = 40
  var swipeLabelViewHeight: CGFloat = 20

  lazy var daySymbolsView: DaySymbolsView = DaySymbolsView(daysInWeek: self.daysInWeek)
  let pagingScrollView = PagingScrollView<DaySelector>()
  lazy var swipeLabelView: SwipeLabelView = SwipeLabelView(date: Date().dateOnly())

  public init(selectedDate: Date) {
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

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
    configurePages()
  }

  func configure() {
    [daySymbolsView, pagingScrollView, swipeLabelView].forEach {
      addSubview($0)
    }
    pagingScrollView.viewDelegate = self
    backgroundColor = style.backgroundColor
  }

  func configurePages(_ selectedDate: Date = Date()) {
    for i in -1...1 {
      let daySelector = DaySelector(daysInWeek: daysInWeek)
      let date = selectedDate.add(TimeChunk(seconds: 0,
                                            minutes: 0,
                                            hours: 0,
                                            days: 0,
                                            weeks: i,
                                            months: 0,
                                            years: 0))
      daySelector.startDate = beginningOfWeek(date)
      pagingScrollView.reusableViews.append(daySelector)
      pagingScrollView.addSubview(daySelector)
      daySelector.delegate = self
    }
    let centerDaySelector = pagingScrollView.reusableViews[1]
    centerDaySelector.selectedDate = selectedDate
    currentWeekdayIndex = centerDaySelector.selectedIndex
  }

  func beginningOfWeek(_ date: Date) -> Date {
    var components = calendar.dateComponents([.year, .month, .day,
                                              .weekday, .timeZone], from: date)
    let offset = components.weekday! - calendar.firstWeekday
    components.day = components.day! - offset

    return calendar.date(from: components)!
  }

  public func selectDate(_ selectedDate: Date) {
    let selectedDate = selectedDate.dateOnly()
    let centerDaySelector = pagingScrollView.reusableViews[1]
    let startDate = centerDaySelector.startDate.dateOnly()

    let daysFrom = selectedDate.days(from: startDate, calendar: calendar)

    if daysFrom < 0 {
      pagingScrollView.scrollBackward()
      currentWeekdayIndex = abs(daysInWeek + daysFrom % daysInWeek)
    } else if daysFrom > daysInWeek - 1 {
      pagingScrollView.scrollForward()
      currentWeekdayIndex = daysFrom % daysInWeek
    } else {
      centerDaySelector.selectedDate = selectedDate
    }

    swipeLabelView.date = selectedDate
    currentDate = selectedDate
  }

  public func updateStyle(_ newStyle: DayHeaderStyle) {
    style = newStyle
    daySymbolsView.updateStyle(style.daySymbols)
    swipeLabelView.updateStyle(style.swipeLabel)
    pagingScrollView.reusableViews.forEach { daySelector in
      daySelector.updateStyle(style.daySelector)
    }
    backgroundColor = style.backgroundColor
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    pagingScrollView.contentOffset = CGPoint(x: bounds.width, y: 0)
    pagingScrollView.contentSize = CGSize(width: bounds.size.width * CGFloat(pagingScrollView.reusableViews.count), height: 0)
    daySymbolsView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: daySymbolsViewHeight)
    pagingScrollView.alignAndFillWidth(align: .underCentered, relativeTo: daySymbolsView, padding: 0, height: pagingScrollViewHeight)
    swipeLabelView.anchorAndFillEdge(.bottom, xPad: 0, yPad: 10, otherSize: swipeLabelViewHeight)
  }
}

extension DayHeaderView: DaySelectorDelegate {
  func dateSelectorDidSelectDate(_ date: Date, index: Int) {
    currentDate = date
    currentWeekdayIndex = index
    swipeLabelView.date = date
    delegate?.dateHeaderDateChanged(date)
  }
}

extension DayHeaderView: PagingScrollViewDelegate {

  func updateViewAtIndex(_ index: Int) {
    let viewToUpdate = pagingScrollView.reusableViews[index]
    let weeksToAdd = index > 1 ? 3 : -3
    viewToUpdate.startDate = viewToUpdate.startDate.add(TimeChunk(seconds: 0,
                                                                  minutes: 0,
                                                                  hours: 0,
                                                                  days: 0,
                                                                  weeks: weeksToAdd,
                                                                  months: 0,
                                                                  years: 0))
  }

  func scrollviewDidScrollToViewAtIndex(_ index: Int) {
    let activeView = pagingScrollView.reusableViews[index]
    activeView.selectedIndex = currentWeekdayIndex
    swipeLabelView.date = activeView.selectedDate!
    delegate?.dateHeaderDateChanged(activeView.selectedDate!)
  }
}
