import UIKit
import Neon

class CurrentTimeIndicator: UIView {

  var leftInset: CGFloat = 53

  var is24hClock = true

  var date = NSDate() {
    didSet {
      let dateFormat = is24hClock ? "HH:mm" : "h:mm a"
      timeLabel.text = date.formattedDateWithFormat(dateFormat)
      timeLabel.sizeToFit()
      setNeedsLayout()
    }
  }

  private var timeLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFontOfSize(11)

    return label
    }()

  private var circle = UIView()

  private var line = UIView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    [timeLabel, circle, line].forEach {
      addSubview($0)
    }
    resetSubviewsColor()
  }

  override func layoutSubviews() {
    let size = timeLabel.frame.size
    timeLabel.align(Align.ToTheLeftCentered, relativeTo: line, padding: 5, width: size.width, height: size.height)

    line.frame = CGRect(x: leftInset - 5, y: bounds.height / 2, width: bounds.width, height: 1)

    circle.frame = CGRect(x: leftInset + 1, y: 0, width: 6, height: 6)
    circle.center.y = line.center.y
    circle.layer.cornerRadius = circle.bounds.height / 2
  }

  override func tintColorDidChange() {
    resetSubviewsColor()
  }

  private func resetSubviewsColor() {
    timeLabel.textColor = tintColor
    circle.backgroundColor = tintColor
    line.backgroundColor = tintColor
  }
}
