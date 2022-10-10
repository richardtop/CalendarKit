import UIKit

public final class SwipeLabelView: UIView, DayViewStateUpdating {
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        return label
    }()
    
    private lazy var separator: UIView = {
      let separator = UIView()
      separator.backgroundColor = SystemColors.systemSeparator
      return separator
    }()
    
    public private(set) var calendar = Calendar.autoupdatingCurrent
    public weak var state: DayViewState? {
        willSet(newValue) {
            state?.unsubscribe(client: self)
        }
        didSet {
            state?.subscribe(client: self)
            updateLabelTextWith(date: state!.selectedDate)
        }
    }
    
    private func updateLabelTextWith(date: Date) {
        var textColor: UIColor?
        if isToday(date: date) {
            textColor = .systemBlue
        } else if isDateInWeekend(date: date) {
            textColor = UIColor.secondaryLabel
        } else {
            textColor = UIColor.label
        }
        
        dateLabel.textColor = textColor
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: isToday(date: date) ? .bold : .medium)
        dateLabel.text = calendarDateStringWithoutCurrentYear(from: date)
    }
    
    private var style = SwipeLabelStyle()
    
    public init(calendar: Calendar = Calendar.autoupdatingCurrent) {
        self.calendar = calendar
        super.init(frame: .zero)
        configure()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        addSubview(dateLabel)
        addSubview(separator)
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separator.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        if isIPad() {
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        } else {
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        }
        
        updateStyle(style)
    }
    
    public func updateStyle(_ newStyle: SwipeLabelStyle) {
        backgroundColor = .tertiarySystemBackground
    }
    
    // MARK: - DayViewStateUpdating
    public func move(from oldDate: Date, to newDate: Date) {
        guard newDate != oldDate
        else { return }
        
        updateLabelTextWith(date: newDate)
    }
    
    // MARK: - DateFormatter
    private let calendarDateFormatWithoutYear = "EEE, dd MMM"

    private func calendarDateStringWithoutCurrentYear(from date: Date) -> String? {
        var dateFormatter = calendarDateFormatter()
        if Date().currentYear() == date.year() {
            dateFormatter = calendarDateFormatter(calendarDateFormatWithoutYear)
        }
        return dateFormatter.string(from: date)
    }
    
    private func calendarDateFormatter(_ template: String = calendarDateFormat) -> DateFormatter {
        let langCode = Locale.preferredLanguages.first
        let locale = (langCode == nil) ? Locale.current : Locale(identifier: langCode!)
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: locale)
        return formatter
    }
    
    private func isDateInWeekend(date: Date) -> Bool {
        return calendar.isDateInWeekend(date)
    }
    
    private func isToday(date: Date) -> Bool {
      calendar.isDateInToday(date)
    }
}

public func isIPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

fileprivate let calendarDateFormat = "EEE, dd MMM yyyy"

