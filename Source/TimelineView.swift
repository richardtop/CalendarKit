import UIKit

class TimelineView: UIView {

  var date = NSDate()

  var hourColor = UIColor.grayColor()
  var timeColor = UIColor.blackColor()
  var lineColor = UIColor.grayColor()

  var timeFont: UIFont {
    return UIFont.systemFontOfSize(fontSize)
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
  }


  override func drawRect(rect: CGRect) {
    super.drawRect(rect)

    var discount = -1

    if isToday {
      let today = NSDate()
      let minute = today.minute()

      if minute > 39 {
        discount = today.hour() + 1
      } else if minute < 21 {
        discount = today.hour()
      }
    }


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

      if i == discount { continue }

      let timeRect = CGRectMake(2.0, iFloat * verticalDiff + verticalInset - 7, leftInset - 2.0 - 6, fontSize + 2.0)
      let timeString = NSString(string: time)
      let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
      style.lineBreakMode = .ByWordWrapping
      style.alignment = .Right
      timeString.drawInRect(timeRect, withAttributes: [NSParagraphStyleAttributeName : style])
    }
  }

  // MARK: - Helpers

  private var onePixel: CGFloat {
    return 1 / UIScreen.mainScreen().scale
  }
}
