import UIKit
import Neon
import DateToolsSwift

protocol DaySelectorDelegate: class {
  func dateSelectorDidSelectDate(_ date: Date, index: Int)
}

class DaySelector: UIView, ReusableView {

  weak var delegate: DaySelectorDelegate?

  var calendar = Calendar.autoupdatingCurrent

  var style = DaySelectorStyle()

  var daysInWeek = 7
  var startDate: Date! {
    didSet {
      configure()
    }
  }

  var selectedIndex = -1 {
    didSet {
      dateLabels.filter {$0.selected == true}
        .first?.selected = false
      if selectedIndex < dateLabels.count && selectedIndex > -1 {
        let label = dateLabels[selectedIndex]
        label.selected = true
      }
    }
  }

  var selectedDate: Date? {
    get {
      return dateLabels.filter{$0.selected == true}.first?.date as Date?
    }
    set(newDate) {
      if let newDate = newDate {
        selectedIndex = newDate.days(from: startDate, calendar: calendar)
      }
    }
  }

  var dateLabelWidth: CGFloat = 35

  var dateLabels = [DateLabel]()

  init(startDate: Date = Date(), daysInWeek: Int = 7) {
    self.startDate = startDate.dateOnly()
    self.daysInWeek = daysInWeek
    super.init(frame: CGRect.zero)
    initializeViews()
    configure()
  }

  override init(frame: CGRect) {
    startDate = Date().dateOnly()
    super.init(frame: frame)
    initializeViews()
  }

  required init?(coder aDecoder: NSCoder) {
    startDate = Date().dateOnly()
    super.init(coder: aDecoder)
    initializeViews()
  }

  func initializeViews() {
    for _ in 1...daysInWeek {
      let label = DateLabel()
      dateLabels.append(label)
      addSubview(label)

      let recognizer = UITapGestureRecognizer(target: self,
        action: #selector(DaySelector.dateLabelDidTap(_:)))
      label.addGestureRecognizer(recognizer)
    }
  }

  func configure() {
    for (increment, label) in dateLabels.enumerated() {
      label.date = startDate.add(TimeChunk(seconds: 0,
                                           minutes: 0,
                                           hours: 0,
                                           days: increment,
                                           weeks: 0,
                                           months: 0,
                                           years: 0))
    }
  }

  func updateStyle(_ newStyle: DaySelectorStyle) {
    style = newStyle
    dateLabels.forEach{ label in
      label.updateStyle(style)
    }
  }

  func prepareForReuse() {
    dateLabels.forEach {$0.selected = false}
  }

  override func layoutSubviews() {
    let dateLabelsCount = CGFloat(dateLabels.count)
    var per = frame.size.width - dateLabelWidth * dateLabelsCount
    per /= dateLabelsCount
    let minX = per / 2

    for (i, label) in dateLabels.enumerated() {
      let frame = CGRect(x: minX + (dateLabelWidth + per) * CGFloat(i), y: 0,
        width: dateLabelWidth, height: dateLabelWidth)
      label.frame = frame
    }
  }

  func dateLabelDidTap(_ sender: UITapGestureRecognizer) {
    if let label = sender.view as? DateLabel {
      selectedIndex = dateLabels.index(of: label)!
      delegate?.dateSelectorDidSelectDate(label.date, index: selectedIndex)
      dateLabels.filter {$0.selected == true}
        .first?.selected = false
      label.selected = true
    }
  }
}
