import UIKit

public final class SwipeLabelView: UIView, DayViewStateUpdating {
    public enum AnimationDirection {
        case Forward
        case Backward
        
        mutating func flip() {
            switch self {
            case .Forward:
                self = .Backward
            case .Backward:
                self = .Forward
            }
        }
    }
    
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
        for (idx, label) in firstLabels.enumerated() {
            label.text = formattedDate(date: state!.selectedDate.addingTimeInterval(TimeInterval(idx * 60 * 60 * 24)))
        }
    }
    
    private var firstLabels: [UILabel] {
        headers.first!.subviews.compactMap{ $0 as? UILabel }
    }
    
    private var secondLabels: [UILabel] {
        headers.last!.subviews.compactMap{ $0 as? UILabel }
    }
    
    private var firstSeparators: [SeparatorView] {
        headers.first!.subviews.compactMap{ $0 as? SeparatorView }
    }
    
    private var secondSeparators: [SeparatorView] {
        headers.last!.subviews.compactMap{ $0 as? SeparatorView }
    }
    
    private var firstHeader: UIView {
        headers.first!
    }
    
    private var secondHeader: UIView {
        headers.last!
    }
    
    private var headers = [UIView]()
    
    private var style = SwipeLabelStyle()
    
    private var presentation: TimelinePresentation = .oneDay
    
    public init(
        calendar: Calendar = Calendar.autoupdatingCurrent,
        presentation: TimelinePresentation
    ) {
        self.calendar = calendar
        super.init(frame: .zero)
        self.presentation = presentation
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
        for i in 0...1 {
            let header = UIView()
            headers.append(header)
            header.tag = i + 2
            addSubview(header)
            if (presentation == .oneDay) {
                let label = UILabel()
                label.textAlignment = .center
                header.addSubview(label)
                let separator = SeparatorView()
                separator.backgroundColor = style.separatorColor
                header.addSubview(separator)
            } else {
                for j in 0...2 {
                    let label = UILabel()
                    label.textAlignment = .center
                    label.tag = i*j
                    header.addSubview(label)
                    let separator = SeparatorView()
                    separator.backgroundColor = style.separatorColor
                    header.addSubview(separator)
                }
            }
        }
        updateStyle(style)
    }
    
    public func updateStyle(_ newStyle: SwipeLabelStyle) {
        style = newStyle
        for label in firstLabels {
            label.textColor = style.textColor
            label.font = style.font
        }
        for label in secondLabels {
            label.textColor = style.textColor
            label.font = style.font
        }
    }
    
    private func animate(_ direction: AnimationDirection) {
        let multiplier: CGFloat = direction == .Forward ? -1 : 1
        let shiftRatio: CGFloat = 30/375
        let screenWidth = bounds.width
        
        secondHeader.alpha = 0
        secondHeader.frame = bounds
        secondHeader.frame.origin.x -= CGFloat(shiftRatio * screenWidth * 3) * multiplier
        
        UIView.animate(withDuration: 0.3, animations: {
            self.secondHeader.frame = self.bounds
            self.firstHeader.frame.origin.x += CGFloat(shiftRatio * screenWidth) * multiplier
            self.secondHeader.alpha = 1
            self.firstHeader.alpha = 0
        }, completion: { _ in
            self.headers = self.headers.reversed()
        })
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        for header in headers {
            header.frame = bounds
        }
        if presentation == .oneDay {
            constrainOneDayLabels()
        } else {
            constrainThreeDaysLabels()
        }
        constrainSeparators()
    }
    
    private func constrainOneDayLabels() {
        let firstLabel = firstLabels.first!
        let secondLabel = secondLabels.first!
        firstLabel.translatesAutoresizingMaskIntoConstraints = false
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            firstLabel.centerYAnchor.constraint(equalTo: firstHeader.centerYAnchor),
            firstLabel.centerXAnchor.constraint(equalTo: firstHeader.centerXAnchor, constant: 30),
            secondLabel.centerYAnchor.constraint(equalTo: secondHeader.centerYAnchor),
            secondLabel.centerXAnchor.constraint(equalTo: secondHeader.centerXAnchor, constant: 30),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func constrainThreeDaysLabels() {
        let third = (bounds.width - 60) / 3
        for (idx, label) in firstLabels.enumerated() {
            label.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                label.centerYAnchor.constraint(equalTo: firstHeader.centerYAnchor),
                label.centerXAnchor.constraint(equalTo: firstHeader.centerXAnchor, constant: CGFloat(idx - 1) * third + 30)
            ]
            NSLayoutConstraint.activate(constraints)
        }
        for (idx, label) in secondLabels.enumerated() {
            label.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                label.centerYAnchor.constraint(equalTo: secondHeader.centerYAnchor),
                label.centerXAnchor.constraint(equalTo: secondHeader.centerXAnchor, constant: CGFloat(idx - 1) * third + 30)
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    private func constrainSeparators() {
        let height: CGFloat = presentation == .oneDay ? 16 : 24
        let width: CGFloat = 1 / UIScreen.main.scale
        let third = (bounds.width - 60) / 3
        for (idx, separator) in firstSeparators.enumerated() {
            separator.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                separator.widthAnchor.constraint(equalToConstant: width),
                separator.heightAnchor.constraint(equalToConstant: height),
                separator.bottomAnchor.constraint(equalTo: firstHeader.bottomAnchor),
                separator.leadingAnchor.constraint(equalTo: firstHeader.leadingAnchor, constant: 60 + (third * CGFloat(idx)))
            ]
            NSLayoutConstraint.activate(constraints)
        }
        for (idx, separator) in secondSeparators.enumerated() {
            separator.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                separator.widthAnchor.constraint(equalToConstant: width),
                separator.heightAnchor.constraint(equalToConstant: height),
                separator.bottomAnchor.constraint(equalTo: secondHeader.bottomAnchor),
                separator.leadingAnchor.constraint(equalTo: secondHeader.leadingAnchor, constant: 60 + (third * CGFloat(idx)))
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    // MARK: DayViewStateUpdating
    
    public func move(from oldDate: Date, to newDate: Date) {
        guard newDate != oldDate
        else { return }
        var direction: AnimationDirection = newDate > oldDate ? .Forward : .Backward
        
        let rightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        if rightToLeft { direction.flip() }
        
        secondLabels.first!.text = formattedDate(date: newDate)
        if (presentation == .threeDays) {
            secondLabels[1].text = formattedDate(date: newDate.addingTimeInterval(60 * 60 * 24))
            secondLabels[2].text = formattedDate(date: newDate.addingTimeInterval(2 * 60 * 60 * 24))
        }
        
        animate(direction)
    }
    
    private func formattedDate(date: Date) -> String {
        let timezone = calendar.timeZone
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d"
        formatter.timeZone = timezone
        formatter.locale = Locale.init(identifier: Locale.preferredLanguages[0])
        return formatter.string(from: date).uppercased()
    }
}

final class SeparatorView: UIView {}
