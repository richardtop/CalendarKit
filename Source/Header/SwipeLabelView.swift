import UIKit

class SwipeLabelView: UIView {

  var date = NSDate() {
    willSet(newDate) {
      guard !newDate.isEqualToDate(date)
        else { return }
      labels.last!.text = newDate.formattedDateWithStyle(.FullStyle)
      let shouldMoveForward = newDate.isLaterThan(date)
      animate(shouldMoveForward)
    }
  }

  var labels = [UILabel]()

  init(date: NSDate) {
    self.date = date
    super.init(frame: CGRect.zero)
    configure()
    labels.last!.text = date.formattedDateWithStyle(.FullStyle)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    for _ in 0...1 {
      let label = UILabel()
      label.textAlignment = .Center
      labels.append(label)
      addSubview(label)
    }
  }

  func animate(forward: Bool) {
    let multiplier: CGFloat = forward ? -1 : 1

    let label = labels.first!
    let secondLabel = labels.last!

    secondLabel.alpha = 0
    secondLabel.frame = bounds
    secondLabel.frame.origin.x -= CGFloat(100) * multiplier

    UIView.animateWithDuration(0.3, animations: { _ in
      secondLabel.frame = self.bounds
      label.frame.origin.x += CGFloat(30) * multiplier
      secondLabel.alpha = 1
      label.alpha = 0
      }) { _ in
        self.labels = self.labels.reverse()
    }
  }

  override func layoutSubviews() {
    for subview in subviews {
      subview.frame = bounds
    }
  }
}
