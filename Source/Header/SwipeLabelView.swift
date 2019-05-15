import UIKit

class SwipeLabelView: UIView {

  enum AnimationDirection {
    case Forward
    case Backward
  }

  var calendar = Calendar.autoupdatingCurrent
  weak var state: DayViewState? {
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

  var firstLabel: UILabel {
    return labels.first!
  }

  var secondLabel: UILabel {
    return labels.last!
  }

  var labels = [UILabel]()

  var style = SwipeLabelStyle()

  init(calendar: Calendar = Calendar.autoupdatingCurrent) {
    self.calendar = calendar
    super.init(frame: .zero)
    configure()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    for _ in 0...1 {
      let label = UILabel()
      label.textAlignment = .center
      labels.append(label)
      addSubview(label)
    }
    updateStyle(style)
  }

  func updateStyle(_ newStyle: SwipeLabelStyle) {
    style = newStyle.copy() as! SwipeLabelStyle
    labels.forEach { label in
      label.textColor = style.textColor
      label.font = style.font
    }
  }

  func animate(_ direction: AnimationDirection) {
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

  override func layoutSubviews() {
    for subview in subviews {
      subview.frame = bounds
    }
  }
}

extension SwipeLabelView: DayViewStateUpdating {
  func move(from oldDate: Date, to newDate: Date) {
    guard newDate != oldDate
      else { return }
    labels.last!.text = formattedDate(date: newDate)
    let direction: AnimationDirection = newDate.isLater(than: oldDate) ? .Forward : .Backward
    animate(direction)
  }

  private func formattedDate(date: Date) -> String {
    let timezone = calendar.timeZone
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .none
    formatter.timeZone = timezone
    return formatter.string(from: date)
  }
}
