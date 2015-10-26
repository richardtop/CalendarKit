import UIKit
import DateTools
import Neon
import DynamicColor

class EventView: UIView {

  var color = UIColor(hue: 0, saturation: 81/100, brightness: 97/100, alpha: 1) {
    didSet {
      [titleLabel, subtitleLabel].forEach {$0.textColor = color.darkenColor(0.3)}
      backgroundColor = UIColor(red: color.redComponent(), green: color.greenComponent(), blue: color.blueComponent(), alpha: 0.3)
    }
  }

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFontOfSize(12)
    label.numberOfLines = 0

    return label
  }()

  var subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFontOfSize(12)
    label.numberOfLines = 0

    return label
  }()

  lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap")
  lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress")

  var datePeriod = DTTimePeriod() {
    didSet {
      subtitleLabel.text = String(datePeriod.StartDate)
    }
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
    clipsToBounds = true
    [tapGestureRecognizer, longPressGestureRecognizer].forEach {addGestureRecognizer($0)}
    [titleLabel, subtitleLabel].forEach{
      addSubview($0)
      $0.numberOfLines = 0
    }
    backgroundColor = color
    addData()
  }

  func addData() {
    titleLabel.text = ""
    subtitleLabel.text = ""
  }

  func tap() {

  }

  func longPress() {
    self.backgroundColor = UIColor(red: color.redComponent(), green: color.greenComponent(), blue: color.blueComponent(), alpha: 1)
    titleLabel.textColor = .whiteColor()
    subtitleLabel.textColor = .whiteColor()
  }

  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    let context = UIGraphicsGetCurrentContext()
    CGContextSetInterpolationQuality(context, .None)
    CGContextSaveGState(context)
    CGContextSetStrokeColorWithColor(context, color.CGColor)
    CGContextSetLineWidth(context, 3)
    CGContextTranslateCTM(context, 0, 0.5)
    let x: CGFloat = 0
    let y: CGFloat = 0
    CGContextBeginPath(context)
    CGContextMoveToPoint(context, x, y)
    CGContextAddLineToPoint(context, x, CGRectGetHeight(bounds))
    CGContextStrokePath(context)
    CGContextRestoreGState(context)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    color = UIColor(hue: 0, saturation: 81/100, brightness: 97/100, alpha: 1)
    titleLabel.anchorInCorner(.TopLeft, xPad: 7, yPad: 5, width: bounds.size.width, height: 50)
    titleLabel.sizeToFit()
    subtitleLabel.alignAndFill(align: .UnderMatchingLeft, relativeTo: titleLabel, padding: 10)
    subtitleLabel.sizeToFit()
  }
}
