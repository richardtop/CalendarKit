import UIKit
import Neon
import DateTools

protocol DaySelectorDelegate: class {
  func dateSelectorDidSelectDate(date: NSDate, index: Int)
}

class DaySelector: UIView {

  weak var delegate: DaySelectorDelegate?

  var calendar = NSCalendar.autoupdatingCurrentCalendar()

  var daysInWeek = 7
  var startDate: NSDate! {
    didSet {
      configure()
    }
  }

  var selectedIndex = -1 {
    didSet {
      dateLabels.filter {$0.selected == true}
        .first?.selected = false
      let label = dateLabels[selectedIndex]
      label.selected = true
    }
  }

  var selectedDate: NSDate? {
    get {
      return dateLabels.filter{$0.selected == true}.first?.date
    }
    set(newDate) {
      if let newDate = newDate {
        selectedIndex = newDate.daysFrom(startDate, calendar: calendar)
      }
    }
  }

  var dateLabelWidth: CGFloat = 35

  var dateLabels = [DateLabel]()

  init(startDate: NSDate = NSDate(), daysInWeek: Int = 7) {
    self.startDate = startDate.dateOnly()
    self.daysInWeek = daysInWeek
    super.init(frame: CGRect.zero)
    initializeViews()
    configure()
  }

  override init(frame: CGRect) {
    startDate = NSDate().dateOnly()
    super.init(frame: frame)
    initializeViews()
  }

  required init?(coder aDecoder: NSCoder) {
    startDate = NSDate().dateOnly()
    super.init(coder: aDecoder)
    initializeViews()
  }

  func initializeViews() {
    for _ in 1...daysInWeek {
      let label = DateLabel()
      dateLabels.append(label)
      addSubview(label)

      let recognizer = UITapGestureRecognizer(target: self,
        action: "dateLabelDidTap:")
      label.addGestureRecognizer(recognizer)
    }
  }

  func configure() {
    for (increment, label) in dateLabels.enumerate() {
      label.date = startDate.dateByAddingDays(increment)
    }
  }

  override func layoutSubviews() {
    let dateLabelsCount = CGFloat(dateLabels.count)
    var per = frame.size.width - dateLabelWidth * dateLabelsCount
    per /= dateLabelsCount
    let minX = per / 2

    //TODO refactor swifty math by applying extension ?
    for (i, label) in dateLabels.enumerate() {
      let frame = CGRect(x: minX + (dateLabelWidth + per) * CGFloat(i), y: 0,
        width: dateLabelWidth, height: dateLabelWidth)
      label.frame = frame
    }
  }

  func dateLabelDidTap(sender: UITapGestureRecognizer) {
    if let label = sender.view as? DateLabel {
      selectedIndex = dateLabels.indexOf(label)!
      delegate?.dateSelectorDidSelectDate(label.date, index: selectedIndex)
      dateLabels.filter {$0.selected == true}
        .first?.selected = false
      label.selected = true
    }
  }
}

extension DaySelector: ReusableView {
  func prepareForReuse() {
    dateLabels.forEach {$0.selected = false}
  }
}
