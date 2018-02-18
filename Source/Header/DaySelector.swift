import UIKit
import Neon
import DateToolsSwift

public protocol DaySelectorItemProtocol: class {
  var date: Date {get set}
  var selected: Bool {get set}
  func updateStyle(_ newStyle: DaySelectorStyle)
}

protocol DaySelectorDelegate: class {
  func dateSelectorDidSelectDate(_ date: Date)
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
      items.filter {$0.selected == true}
        .first?.selected = false
      if selectedIndex < items.count && selectedIndex > -1 {
        let label = items[selectedIndex]
        label.selected = true
      }
    }
  }

  var selectedDate: Date? {
    get {
      return items.filter{$0.selected == true}.first?.date as Date?
    }
    set(newDate) {
      if let newDate = newDate {
        selectedIndex = newDate.days(from: startDate, calendar: calendar)
      }
    }
  }

  var items = [UIView & DaySelectorItemProtocol]()

  init(startDate: Date = Date(), daysInWeek: Int = 7) {
    self.startDate = startDate.dateOnly()
    self.daysInWeek = daysInWeek
    super.init(frame: CGRect.zero)
    initializeViews(viewType: DayDateCell.self)
    configure()
  }

  override init(frame: CGRect) {
    startDate = Date().dateOnly()
    super.init(frame: frame)
    initializeViews(viewType: DayDateCell.self)
  }

  required init?(coder aDecoder: NSCoder) {
    startDate = Date().dateOnly()
    super.init(coder: aDecoder)
    initializeViews(viewType: DayDateCell.self)
  }

  func initializeViews<T: UIView>(viewType: T.Type) where T: DaySelectorItemProtocol {
    // Remove previous Items
    items.forEach{$0.removeFromSuperview()}

    // Create new with corresponding class
    for _ in 1...daysInWeek {
      let label = T()
      items.append(label)
      addSubview(label)

      let recognizer = UITapGestureRecognizer(target: self,
                                              action: #selector(DaySelector.dateLabelDidTap(_:)))
      label.addGestureRecognizer(recognizer)
    }
  }


  func configure() {
    for (increment, label) in items.enumerated() {
      label.date = startDate.add(TimeChunk.dateComponents(days: increment))
    }
  }

  func updateStyle(_ newStyle: DaySelectorStyle) {
    style = newStyle.copy() as! DaySelectorStyle
    items.forEach{ label in
      label.updateStyle(style)
    }
  }

  func prepareForReuse() {
    items.forEach {$0.selected = false}
  }

  override func layoutSubviews() {
    let dateLabelsCount = CGFloat(items.count)
    let size = items.first?.intrinsicContentSize ?? .zero

    var per = frame.size.width - size.width * dateLabelsCount
    per /= dateLabelsCount
    let minX = per / 2

    for (i, label) in items.enumerated() {
      let frame = CGRect(x: minX + (size.width + per) * CGFloat(i), y: 0,
                         width: size.width, height: size.height)
      label.frame = frame
    }
  }

  @objc func dateLabelDidTap(_ sender: UITapGestureRecognizer) {
    if let item = sender.view as? DaySelectorItemProtocol {
      delegate?.dateSelectorDidSelectDate(item.date)
    }
  }
}
