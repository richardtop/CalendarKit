import UIKit
import DateToolsSwift
import Neon

class DayDateCell: UIView, DaySelectorItemProtocol {

  let dateLabel = DateLabel()
  let dayLabel = UILabel()

  var regularSizeClassFontSize: CGFloat = 16

  var date = Date() {
    didSet {
      dateLabel.date = date
      updateState()
    }
  }

  var calendar = Calendar.autoupdatingCurrent {
    didSet {
      dateLabel.calendar = calendar
      updateState()
    }
  }


  var selected: Bool {
    get {
      return dateLabel.selected
    }
    set(value) {
      dateLabel.selected = value
    }
  }

  var style = DaySelectorStyle()

  override var intrinsicContentSize: CGSize {
    return CGSize(width: 75, height: 35)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    clipsToBounds = true
    [dayLabel, dateLabel].forEach(addSubview(_:))
  }

  func updateStyle(_ newStyle: DaySelectorStyle) {
    style = newStyle
    dateLabel.updateStyle(newStyle)
    updateState()
  }

  func updateState() {
    let isWeekend = isAWeekend(date: date)
    dayLabel.font = UIFont.systemFont(ofSize: regularSizeClassFontSize)
    dayLabel.textColor = isWeekend ? style.weekendTextColor : style.inactiveTextColor
    dateLabel.updateState()
    updateDayLabel()
    setNeedsLayout()
  }

  func updateDayLabel() {
    let daySymbols = calendar.shortWeekdaySymbols
    let weekendMask = [true] + [Bool](repeating: false, count: 5) + [true]
    var weekDays = Array(zip(daySymbols, weekendMask))
    weekDays.shift(calendar.firstWeekday - 1)
    let weekDay = component(component: .weekday, from: date)
    dayLabel.text = daySymbols[weekDay - 1]
  }

  private func component(component: Calendar.Component, from date: Date) -> Int {
    return calendar.component(component, from: date)
  }

  private func isAWeekend(date: Date) -> Bool {
    let weekday = component(component: .weekday, from: date)
    if weekday == 7 || weekday == 1 {
      return true
    }
    return false
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    dayLabel.sizeToFit()
    dayLabel.center.y = center.y
    let interItemSpacing: CGFloat = selected ? 5 : 3
    dateLabel.align(.toTheRightCentered,
                    relativeTo: dayLabel,
                    padding: interItemSpacing,
                    width: 30, height: 30)

    let freeSpace = bounds.width - (dateLabel.frame.origin.x + dateLabel.frame.width)
    let padding = freeSpace / 2
    [dayLabel, dateLabel].forEach { (label) in
      label.frame.origin.x += padding
    }
  }
  override func tintColorDidChange() {
    updateState()
  }
}
