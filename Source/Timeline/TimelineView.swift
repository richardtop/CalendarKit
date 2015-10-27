import UIKit
import Neon
import DateTools

class TimelineView: UIView {

  var date = NSDate() {
    didSet {
      label.text = date.formattedDateWithFormat("dd:MM:  hh:mm")
      setNeedsDisplay()
    }
  }

  var currentTime: NSDate {
    return NSDate()
  }

  var eventViews = [EventView]() {
    willSet(newViews) {
      eventViews.forEach {$0.removeFromSuperview()}
    }

    didSet {
      setNeedsDisplay()
      eventViews.forEach {addSubview($0)}
    }
  }

  //IFDEF DEBUG

  lazy var label = UILabel()

  lazy var nowLine: CurrentTimeIndicator = CurrentTimeIndicator()

  var hourColor = UIColor.lightGrayColor()
  var timeColor = UIColor.lightGrayColor()
  var lineColor = UIColor.lightGrayColor()

  var timeFont: UIFont {
    return UIFont.boldSystemFontOfSize(fontSize)
  }

  var verticalDiff: CGFloat = 45
  var verticalInset: CGFloat = 10
  var leftInset: CGFloat = 53

  var horizontalEventInset: CGFloat = 3

  var fullHeight: CGFloat {
    return verticalInset * 2 + verticalDiff * 24
  }

  var calendarWidth: CGFloat {
    return bounds.width - leftInset
  }

  var fontSize: CGFloat = 11

  var is24hClock = true {
    didSet {
      setNeedsDisplay()
    }
  }

  init() {
    super.init(frame: CGRect.zero)
    frame.size.height = fullHeight
    configure()
  }

  var times: [String] {
    return is24hClock ? _24hTimes : _12hTimes
  }

  private lazy var _12hTimes: [String] = Generator.timeStrings12H()
  private lazy var _24hTimes: [String] = Generator.timeStrings24H()

  var isToday: Bool {
    //TODO: Check for performance on device
    return date.isToday()
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
    contentScaleFactor = 1
    layer.contentsScale = 1
    contentMode = UIViewContentMode.Redraw
    backgroundColor = .whiteColor()
    addSubview(nowLine)
    addSubview(label)
  }

  override func drawRect(rect: CGRect) {
    super.drawRect(rect)

    var hourToRemoveIndex = -1

    if isToday {
      let minute = currentTime.minute()
      if minute > 39 {
        hourToRemoveIndex = currentTime.hour() + 1
      } else if minute < 21 {
        hourToRemoveIndex = currentTime.hour()
      }
    }

    let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy()
      as! NSMutableParagraphStyle

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

      let timeRect = CGRect(x: 2, y: iFloat * verticalDiff + verticalInset - 7,
        width: leftInset - 8, height: fontSize + 2)

      let timeString = NSString(string: time)

      timeString.drawInRect(timeRect, withAttributes: attributes)
    }
  }

  override func layoutSubviews() {
    //TODO: Remove this label. Shows current day for testing purposes
    label.sizeToFit()
    label.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 375, height: 50))

    layoutNowLine()
    layoutEvents()
  }

  func layoutNowLine() {
    if !isToday {
      nowLine.alpha = 0
      return
    }
    nowLine.alpha = 1
    let size = CGSize(width: bounds.size.width, height: 20)
    let rect = CGRect(origin: CGPoint.zero, size: size)
    nowLine.date = currentTime
    nowLine.frame = rect
    nowLine.center.y = dateToY(currentTime)
  }

  func layoutEvents() {
    if eventViews.isEmpty {return}

    let day = DTTimePeriod(size: .Day, startingAt:date)

    let validEvents = eventViews.filter {$0.datePeriod.overlapsWith(day)}
      .sort {$0.datePeriod.StartDate.isEarlierThan($1.datePeriod.StartDate)}

    var groupsOfEvents = [[EventView]]()
    var overlappingEvents = [EventView]()

    for event in validEvents {
      if overlappingEvents.isEmpty {
        overlappingEvents.append(event)
        continue
      }
      if overlappingEvents.last!.datePeriod.overlapsWith(event.datePeriod) {
        overlappingEvents.append(event)
        continue
      }
      groupsOfEvents.append(overlappingEvents)
      overlappingEvents.removeAll()
    }

    for overlappingEvents in groupsOfEvents {
      let totalCount = CGFloat(overlappingEvents.count)

      for (index, event) in overlappingEvents.enumerate() {
        let startY = dateToY(event.datePeriod.StartDate)
        let endY = dateToY(event.datePeriod.EndDate)

        //TODO: Swift math
        let floatIndex = CGFloat(index)
        let x = leftInset + floatIndex / totalCount * calendarWidth

        let equalWidth = calendarWidth / totalCount

        event.frame = CGRect(x: x, y: startY, width: equalWidth, height: endY - startY)
      }
    }
  }

  func eventSafeZone(event: EventView) -> CGFloat {
    return event.frame.origin.y + event.contentHeight
  }

  // MARK: - Helpers

  private var onePixel: CGFloat {
    return 1 / UIScreen.mainScreen().scale
  }

  private func dateToY(date: NSDate) -> CGFloat {
    let hourY = CGFloat(date.hour()) * verticalDiff + verticalInset
    let minuteY = CGFloat(date.minute()) * verticalDiff / 60
    return hourY + minuteY
  }
}
