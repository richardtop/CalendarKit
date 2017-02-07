import UIKit

class SwipeLabelView: UIView {

  var date = Date() {
    willSet(newDate) {
      guard newDate != date
        else { return }
      labels.last!.text = newDate.format(with: .full)
      let shouldMoveForward = newDate.isLater(than: date)
      animate(shouldMoveForward)
    }
  }
  
  var firstLabel: UILabel {
    return labels.first!
  }
  
  var secondLabel: UILabel {
    return labels.last!
  }
  
  var labels = [UILabel]()

  var style = SwipeLabelStyle()

  init(date: Date) {
    self.date = date
    super.init(frame: .zero)
    configure()
    labels.first!.text = date.format(with: .full)
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
      label.textAlignment = .center
      labels.append(label)
      addSubview(label)
    }
    updateStyle(style)
  }

  func updateStyle(_ newStyle: SwipeLabelStyle) {
    style = newStyle
    labels.forEach { label in
      label.textColor = style.textColor
    }
  }

  func animate(_ forward: Bool) {
    let multiplier: CGFloat = forward ? -1 : 1
    let shiftRatio: CGFloat = 30/375
    let screenWidth = bounds.width

    secondLabel.alpha = 0
    secondLabel.frame = bounds
    secondLabel.frame.origin.x -= CGFloat(shiftRatio * screenWidth * 3) * multiplier

    UIView.animate(withDuration: 0.3, animations: { _ in
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
