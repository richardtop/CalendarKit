import UIKit

class DaySymbolsView: UIView {
  var daysInWeek = 7

  var calendar = NSCalendar.autoupdatingCurrentCalendar()

  var labels = [UILabel]()

  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeViews()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeViews()
  }

  func initializeViews() {
    for _ in 1...daysInWeek {
      let label = UILabel()
      label.font = UIFont.systemFontOfSize(10)
      label.textAlignment = .Center
      labels.append(label)
      addSubview(label)
    }
    configure()
  }

  func configure() {
    var daySymbols = calendar.shortWeekdaySymbols
      .map { String($0.characters.first!)}

    // Adjust for first weekday
    daySymbols.shift(calendar.firstWeekday - 1)

    for (index, label) in labels.enumerate() {
      label.text = daySymbols[index]
    }
  }

  override func layoutSubviews() {
    let labelsCount = CGFloat(labels.count)

    var per = bounds.width - bounds.height * labelsCount
    per /= labelsCount

    let minX = per / 2
    //TODO refactor swifty math by applying extension ?
    for (i, label) in labels.enumerate() {
      let frame = CGRect(x: minX + (bounds.height + per) * CGFloat(i), y: 0,
        width: bounds.height, height: bounds.height)
      label.frame = frame
    }
  }
}
