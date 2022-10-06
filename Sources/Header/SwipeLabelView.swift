import UIKit

public final class SwipeLabelView: UIView, DayViewStateUpdating {
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    public private(set) var calendar = Calendar.autoupdatingCurrent
    public weak var state: DayViewState? {
        willSet(newValue) {
            state?.unsubscribe(client: self)
        }
        didSet {
            state?.subscribe(client: self)
            updateLabelText()
        }
    }
    
    private func updateLabelText() {
        dateLabel.text = formattedDate(date: state!.selectedDate)
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
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            dateLabel.heightAnchor.constraint(equalToConstant: 17)
        ])
        updateStyle(style)
    }
    
    public func updateStyle(_ newStyle: SwipeLabelStyle) {
        style = newStyle
        dateLabel.textColor = style.textColor
        dateLabel.font = style.font
    }
    
    // MARK: - DayViewStateUpdating
    public func move(from oldDate: Date, to newDate: Date) {
        guard newDate != oldDate
        else { return }
        dateLabel.text = formattedDate(date: newDate)
    }
    
    private func formattedDate(date: Date) -> String {
        let timezone = calendar.timeZone
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.timeZone = timezone
        formatter.locale = Locale.init(identifier: Locale.preferredLanguages[0])
        return formatter.string(from: date)
    }
}
