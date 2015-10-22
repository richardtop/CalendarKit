import UIKit
import Neon
import DateTools

protocol DayHeaderViewDelegate: class {

}

class DayHeaderView: UIView {

  var calendar = NSCalendar.autoupdatingCurrentCalendar()

  var daySymbolsViewHeight: CGFloat = 17
  var pagingScrollViewHeight: CGFloat = 50
  var swipeLabelViewHeight: CGFloat = 20

  let daySymbolsView = DaySymbolsView()
  let pagingScrollView = PagingScrollView()
  let swipeLabelView = SwipeLabelView()

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
    [daySymbolsView, pagingScrollView, swipeLabelView]
      .forEach {
        addSubview($0)
        $0.backgroundColor = .whiteColor()
    }
    swipeLabelView.layoutSubviews()
    configurePages()
    pagingScrollView.viewDelegate = self
  }

  func configurePages() {
    for i in 0...2 {
      let daySelector = DaySelector()
      let offset = i - 1
      let date = NSDate().dateByAddingWeeks(offset)

      daySelector.startDate = beginningOfWeek(date)
      pagingScrollView.reusableViews.append(daySelector)
      pagingScrollView.addSubview(daySelector)
      daySelector.delegate = self
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    pagingScrollView.contentSize = CGSize(width: bounds.size.width * CGFloat(pagingScrollView.reusableViews.count), height: 0)

    daySymbolsView.anchorAndFillEdge(.Top, xPad: 0, yPad: 0, otherSize: daySymbolsViewHeight)
    pagingScrollView.alignAndFillWidth(align: .UnderCentered, relativeTo: daySymbolsView, padding: 0, height: pagingScrollViewHeight)
    swipeLabelView.anchorAndFillEdge(.Bottom, xPad: 0, yPad: 0, otherSize: swipeLabelViewHeight)
  }
}

extension DayHeaderView: DaySelectorDelegate {
  func dateSelectorDidSelectDate(date: NSDate) {
    swipeLabelView.date = date
  }

  func beginningOfWeek(date: NSDate) -> NSDate {
    let components = calendar.components([.Year, .Month, .Day, .TimeZone, .Weekday], fromDate: date)
    let offset = components.weekday - calendar.firstWeekday
    components.day = components.day - offset

    return calendar.dateFromComponents(components)!
  }
}

extension DayHeaderView: PagingScrollViewDelegate {
  func viewRequiresUpdate(view: UIView, viewBefore: UIView) {
    let viewToUpdate = view as! DaySelector
    let newStartDate = viewToUpdate.startDate.dateByAddingWeeks(3)
    viewToUpdate.startDate = newStartDate
  }

  func viewRequiresUpdate(view: UIView, viewAfter: UIView) {
    let viewToUpdate = view as! DaySelector
    let newStartDate = viewToUpdate.startDate.dateByAddingWeeks(-3)
    viewToUpdate.startDate = newStartDate
  }
}