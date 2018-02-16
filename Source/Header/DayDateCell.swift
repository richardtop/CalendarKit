import UIKit
import DateToolsSwift
import Neon

class DayDateCell: UIView {

  let dateLabel = DateLabel()
  let dayLabel = UILabel()

  var fontSize: CGFloat = 16

  var date = Date() {
    didSet {
      dateLabel.date = date
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

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    layer.borderColor = UIColor.red.cgColor
    layer.borderWidth = 2
    clipsToBounds = true
    [dayLabel, dateLabel].forEach(addSubview(_:))
  }

  func updateStyle(_ newStyle: DaySelectorStyle) {
    style = newStyle
    updateState()
  }

  func updateState() {
    dateLabel.textColor = date.isWeekend ? style.weekendTextColor : style.inactiveTextColor
//    dateLabel.fontSize = fontSize
    dateLabel.updateState()
    dayLabel.font = UIFont.systemFont(ofSize: fontSize)
    updateDayLabel()
    setNeedsLayout()
  }

  func updateDayLabel() {
    let calendar = Calendar.autoupdatingCurrent
    let daySymbols = calendar.shortWeekdaySymbols
    let weekendMask = [true] + [Bool](repeating: false, count: 5) + [true]
    var weekDays = Array(zip(daySymbols, weekendMask))
    weekDays.shift(calendar.firstWeekday - 1)
    dayLabel.text = daySymbols[date.weekday - 1]
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    dayLabel.sizeToFit()
    dayLabel.center.y = center.y
    dateLabel.align(.toTheRightCentered, relativeTo: dayLabel, padding: 2, width: 25, height: 25)

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
