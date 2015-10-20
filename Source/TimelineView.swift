import UIKit

class TimelineView: UIView {

  var date = NSDate()

  var hourColor = UIColor.lightGrayColor()
  var timeColor = UIColor.lightGrayColor()
  var lineColor = UIColor.lightGrayColor()

  var timeFont: UIFont {
    return UIFont.systemFontOfSize(fontSize, weight: 0.2)
  }

  var verticalDiff: CGFloat = 45
  var verticalInset: CGFloat = 10
  var leftInset: CGFloat = 53
  var fontSize: CGFloat = 11

  var is24hClock = true {
    didSet {
      setNeedsDisplay()
    }
  }

  var times: [String] {
    return is24hClock ? _24hTimes : _12hTimes
  }

  private lazy var _12hTimes: [String] = Generator.timeStrings12H()
  private lazy var _24hTimes: [String] = Generator.timeStrings24H()

  //TODO refactor to computed property?
  var isToday = false

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    contentScaleFactor = 1
    layer.contentsScale = 1
    contentMode = UIViewContentMode.Redraw
    backgroundColor = .whiteColor()
  }

  override func drawRect(rect: CGRect) {
    super.drawRect(rect)

    var hourToRemoveIndex = -1

    if isToday {
      let today = NSDate()
      let minute = today.minute()

      if minute > 39 {
        hourToRemoveIndex = today.hour() + 1
      } else if minute < 21 {
        hourToRemoveIndex = today.hour()
      }
    }

    let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
    style.lineBreakMode = .ByWordWrapping
    style.alignment = .Right
    let attributes = [NSParagraphStyleAttributeName: style,
      NSForegroundColorAttributeName: timeColor,
      NSFontAttributeName: timeFont]

    for (i, time) in times.enumerate() {
      let iFloat = CGFloat(i)
      let context = UIGraphicsGetCurrentContext()
      CGContextSetInterpolationQuality(context, .None)
      CGContextSaveGState(context)
      CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
      CGContextSetLineWidth(context, onePixel)
      CGContextTranslateCTM(context, 0, 0.5)
      let x: CGFloat = 53
      let y = verticalInset + iFloat * verticalDiff
      CGContextBeginPath(context)
      CGContextMoveToPoint(context, x, y)
      CGContextAddLineToPoint(context, CGRectGetWidth(bounds), y)
      CGContextStrokePath(context)
      CGContextRestoreGState(context)

      if i == hourToRemoveIndex { continue }

      let timeRect = CGRectMake(2.0, iFloat * verticalDiff + verticalInset - 7, leftInset - 2.0 - 6, fontSize + 2.0)
      let timeString = NSString(string: time)

      timeString.drawInRect(timeRect, withAttributes: attributes)
    }
  }

  // MARK: - Helpers

  private var onePixel: CGFloat {
    return 1 / UIScreen.mainScreen().scale
  }
}
