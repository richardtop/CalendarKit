import UIKit
import DateTools
import Neon
import DynamicColor

class EventView: UIView {

  var color = UIColor() {
    didSet {
      textView.textColor = color.darkenColor(0.3)
      backgroundColor = UIColor(red: color.redComponent(), green: color.greenComponent(), blue: color.blueComponent(), alpha: 0.3)
    }
  }

  var contentHeight: CGFloat {
    //TODO: use strings array to calculate height
    return textView.height
  }

  var data = [String]() {
    didSet {
      textView.text = data.reduce("", combine: {$0 + $1 + "\n"})
    }
  }

  lazy var textView: UITextView = {
    let view = UITextView()
    view.font = UIFont.boldSystemFontOfSize(12)
    view.userInteractionEnabled = false
    view.backgroundColor = UIColor.clearColor()

    return view
  }()

  lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap")
  lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress")

  var datePeriod = DTTimePeriod()

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

    color = tintColor
    addSubview(textView)
  }

  func tap() {

  }

  func longPress() {
    backgroundColor = UIColor(red: color.redComponent(), green: color.greenComponent(), blue: color.blueComponent(), alpha: 1)
    textView.textColor = .whiteColor()
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
    textView.fillSuperview()
  }
}
