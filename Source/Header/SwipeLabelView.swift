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
    labels.first!.text = formattedDate(date: state!.selectedDate)
  }

  private var firstLabel: UILabel {
    return labels.first!
  }

  private var secondLabel: UILabel {
    return labels.last!
  }

  private var labels = [UILabel]()

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
    for _ in 0...1 {
      let label = UILabel()
      label.textAlignment = .center
      labels.append(label)
      addSubview(label)
    }
    updateStyle(style)
  }

  public func updateStyle(_ newStyle: SwipeLabelStyle) {
    style = newStyle
    labels.forEach { label in
      label.textColor = style.textColor
      label.font = style.font
    }
  }

  private func animate(_ direction: AnimationDirection) {
    let multiplier: CGFloat = direction == .Forward ? -1 : 1
    let shiftRatio: CGFloat = 30/375
    let screenWidth = bounds.width

    secondLabel.alpha = 0
    secondLabel.frame = bounds
    secondLabel.frame.origin.x -= CGFloat(shiftRatio * screenWidth * 3) * multiplier

    UIView.animate(withDuration: 0.3, animations: { 
      self.secondLabel.frame = self.bounds
      self.firstLabel.frame.origin.x += CGFloat(shiftRatio * screenWidth) * multiplier
      self.secondLabel.alpha = 1
      self.firstLabel.alpha = 0
    }, completion: { _ in
      self.labels = self.labels.reversed()
    })
  }

  override public func layoutSubviews() {
    for subview in subviews {
      subview.frame = bounds
    }
  }

  // MARK: DayViewStateUpdating

  public func move(from oldDate: Date, to newDate: Date) {
    guard newDate != oldDate
      else { return }
    labels.last!.text = formattedDate(date: newDate)
    
    var direction: AnimationDirection = newDate > oldDate ? .Forward : .Backward
    
    let rightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
    if rightToLeft { direction.flip() }
    
    animate(direction)
  }

  private func formattedDate(date: Date) -> String {
    let timezone = calendar.timeZone
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .none
    formatter.timeZone = timezone
    formatter.locale = Locale.init(identifier: Locale.preferredLanguages[0])
    return formatter.string(from: date)
  }
}
