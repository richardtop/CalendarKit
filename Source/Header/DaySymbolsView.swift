import UIKit

class DaySymbolsView: UIView {

  var daysInWeek = 7
  var calendar = Calendar.autoupdatingCurrent
  var labels = [UILabel]()
  var style: DaySymbolsStyle = DaySymbolsStyle()

  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeViews()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeViews()
  }

  init(daysInWeek: Int = 7, calendar: Calendar = Calendar.autoupdatingCurrent) {
    self.calendar = calendar
    self.daysInWeek = daysInWeek
    super.init(frame: CGRect.zero)
    initializeViews()
  }

  func initializeViews() {
    for _ in 1...daysInWeek {
      let label = UILabel()
      label.textAlignment = .center
      labels.append(label)
      addSubview(label)
    }
    configure()
  }

  func updateStyle(_ newStyle: DaySymbolsStyle) {
    style = newStyle.copy() as! DaySymbolsStyle
    configure()
  }

  func configure() {
    let daySymbols = calendar.veryShortWeekdaySymbols
    let weekendMask = [true] + [Bool](repeating: false, count: 5) + [true]
    var weekDays = Array(zip(daySymbols, weekendMask))

    weekDays.shift(calendar.firstWeekday - 1)

    for (index, label) in labels.enumerated() {
      label.text = weekDays[index].0
      label.textColor = weekDays[index].1 ? style.weekendColor : style.weekDayColor
      label.font = style.font
    }
  }


  override func layoutSubviews() {
    let labelsCount = CGFloat(labels.count)

    var per = bounds.width - bounds.height * labelsCount
    per /= labelsCount

    let minX = per / 2
    for (i, label) in labels.enumerated() {
      let frame = CGRect(x: minX + (bounds.height + per) * CGFloat(i), y: 0,
                         width: bounds.height, height: bounds.height)
      label.frame = frame
    }
  }
}
