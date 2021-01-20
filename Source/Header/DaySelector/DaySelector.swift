import UIKit

public protocol DaySelectorItemProtocol: AnyObject {
  var date: Date {get set}
  var selected: Bool {get set}
  var calendar: Calendar {get set}
  func updateStyle(_ newStyle: DaySelectorStyle)
}

public protocol DaySelectorDelegate: AnyObject {
  func dateSelectorDidSelectDate(_ date: Date)
}

public final class DaySelector: UIView {
  public weak var delegate: DaySelectorDelegate?

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

  private var style = DaySelectorStyle()

  private var daysInWeek = 7
  public var startDate: Date! {
    didSet {
      configure()
    }
  }

  public var selectedIndex = -1 {
    didSet {
      items.filter {$0.selected == true}
        .first?.selected = false
      if selectedIndex < items.count && selectedIndex > -1 {
        let label = items[selectedIndex]
        label.selected = true
      }
    }
  }

  public var selectedDate: Date? {
    get {
      return items.filter{$0.selected == true}.first?.date as Date?
    }
    set(newDate) {
      if let newDate = newDate {
        selectedIndex = calendar.dateComponents([.day], from: startDate, to: newDate).day!
      }
    }
  }

  private var items = [UIView & DaySelectorItemProtocol]()

  public init(startDate: Date = Date(), daysInWeek: Int = 7) {
    self.startDate = startDate.dateOnly(calendar: calendar)
    self.daysInWeek = daysInWeek
    super.init(frame: CGRect.zero)
    initializeViews(viewType: DateLabel.self)
    configure()
  }

  override public init(frame: CGRect) {
    startDate = Date().dateOnly(calendar: calendar)
    super.init(frame: frame)
    initializeViews(viewType: DateLabel.self)
  }

  required public init?(coder aDecoder: NSCoder) {
    startDate = Date().dateOnly(calendar: calendar)
    super.init(coder: aDecoder)
    initializeViews(viewType: DateLabel.self)
  }

  private func initializeViews<T: UIView>(viewType: T.Type) where T: DaySelectorItemProtocol {
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

  private func configure() {
    for (increment, label) in items.enumerated() {
      label.date = calendar.date(byAdding: .day, value: increment, to: startDate)!
    }
  }

  public func updateStyle(_ newStyle: DaySelectorStyle) {
    style = newStyle
    items.forEach{$0.updateStyle(style)}
  }

  public func prepareForReuse() {
    items.forEach {$0.selected = false}
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    let itemCount = CGFloat(items.count)
    let size = items.first?.intrinsicContentSize ?? .zero

    let parentWidth = bounds.size.width

    var per = parentWidth - size.width * itemCount
    per /= itemCount
    let minX = per / 2

    for (i, item) in items.enumerated() {
        
        var x = minX + (size.width + per) * CGFloat(i)
        
        let rightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        if rightToLeft {
            x = parentWidth - x - size.width
        }
        
        let origin = CGPoint(x: x,
                           y: 0)
        let frame = CGRect(origin: origin,
                         size: size)
        item.frame = frame
    }
  }

  public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
    switch sizeClass {
    case .regular:
      initializeViews(viewType: DayDateCell.self)
    default:
      initializeViews(viewType: DateLabel.self)
    }
  }

  @objc private func dateLabelDidTap(_ sender: UITapGestureRecognizer) {
    if let item = sender.view as? DaySelectorItemProtocol {
      delegate?.dateSelectorDidSelectDate(item.date)
    }
  }
}
