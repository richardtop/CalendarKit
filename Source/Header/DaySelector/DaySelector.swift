import UIKit
import Neon
import DateToolsSwift

public protocol DaySelectorItemProtocol: AnyObject {
  var date: Date {get set}
  var selected: Bool {get set}
  var calendar: Calendar {get set}
  func updateStyle(_ newStyle: DaySelectorStyle)
}

protocol DaySelectorDelegate: AnyObject {
  func dateSelectorDidSelectDate(_ date: Date)
}

class DaySelector: UIView {

  weak var delegate: DaySelectorDelegate?

  public var calendar = Calendar.autoupdatingCurrent {
    didSet {
      updateItemsCalendar()
    }
  }

  private func updateItemsCalendar() {
    items.forEach { (item) in
      item.calendar = calendar
    }
  }

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
    self.startDate = startDate.dateOnly(calendar: calendar)
    self.daysInWeek = daysInWeek
    super.init(frame: CGRect.zero)
    initializeViews(viewType: DateLabel.self)
    configure()
  }

  override init(frame: CGRect) {
    startDate = Date().dateOnly(calendar: calendar)
    super.init(frame: frame)
    initializeViews(viewType: DateLabel.self)
  }

  required public init?(coder aDecoder: NSCoder) {
    startDate = Date().dateOnly(calendar: calendar)
    super.init(coder: aDecoder)
    initializeViews(viewType: DateLabel.self)
  }

  func initializeViews<T: UIView>(viewType: T.Type) where T: DaySelectorItemProtocol {
    // Store last selected date
    let lastSelectedDate = selectedDate

    // Remove previous Items
    items.forEach{$0.removeFromSuperview()}
    items.removeAll()

    // Create new with corresponding class
    for _ in 1...daysInWeek {
      let label = T()
      items.append(label)
      addSubview(label)

      let recognizer = UITapGestureRecognizer(target: self,
                                              action: #selector(DaySelector.dateLabelDidTap(_:)))
      label.addGestureRecognizer(recognizer)
    }
    configure()
    updateItemsCalendar()
    // Restore last date
    selectedDate = lastSelectedDate
  }

  func configure() {
    for (increment, label) in items.enumerated() {
      label.date = startDate.add(TimeChunk.dateComponents(days: increment), calendar: calendar)
    }
  }

  func updateStyle(_ newStyle: DaySelectorStyle) {
    style = newStyle.copy() as! DaySelectorStyle
    items.forEach{$0.updateStyle(style)}
  }

  func prepareForReuse() {
    items.forEach {$0.selected = false}
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let itemCount = CGFloat(items.count)
    let size = items.first?.intrinsicContentSize ?? .zero

    let parentWidth = bounds.size.width

    var per = parentWidth - size.width * itemCount
    per /= itemCount
    let minX = per / 2

    for (i, item) in items.enumerated() {
      let origin = CGPoint(x: minX + (size.width + per) * CGFloat(i),
                           y: 0)
      let frame = CGRect(origin: origin,
                         size: size)
      item.frame = frame
    }
  }

  func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
    switch sizeClass {
    case .regular:
      initializeViews(viewType: DayDateCell.self)
    default:
      initializeViews(viewType: DateLabel.self)
    }
  }

  @objc func dateLabelDidTap(_ sender: UITapGestureRecognizer) {
    if let item = sender.view as? DaySelectorItemProtocol {
      delegate?.dateSelectorDidSelectDate(item.date)
    }
  }
}
