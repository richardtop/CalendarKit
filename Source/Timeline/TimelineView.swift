import UIKit
import Neon
import DateToolsSwift

public class TimelineView: UIView, ReusableView {

  var date = Date() {
    didSet {
      setNeedsLayout()
    }
  }

  var currentTime: Date {
    return Date()
  }

  var eventViews = [EventView]() {
    willSet {
      eventViews.forEach {$0.removeFromSuperview()}
    }
    didSet {
      eventViews.forEach {addSubview($0)}
      setNeedsLayout()
    }
  }

  lazy var nowLine: CurrentTimeIndicator = CurrentTimeIndicator()

  var style = TimelineStyle()

  var timeFont: UIFont {
    return UIFont.boldSystemFont(ofSize: fontSize)
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
    super.init(frame: .zero)
    frame.size.height = fullHeight
    configure()
  }

  var times: [String] {
    return is24hClock ? _24hTimes : _12hTimes
  }

  fileprivate lazy var _12hTimes: [String] = Generator.timeStrings12H()
  fileprivate lazy var _24hTimes: [String] = Generator.timeStrings24H()

  var isToday: Bool {
    return date.isToday
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
    contentScaleFactor = 1
    layer.contentsScale = 1
    contentMode = .redraw
    backgroundColor = .white
    addSubview(nowLine)
  }

  public func updateStyle(_ newStyle: TimelineStyle) {
    style = newStyle
    nowLine.updateStyle(style.timeIndicator)
    backgroundColor = style.backgroundColor
    setNeedsDisplay()
  }

  override public func draw(_ rect: CGRect) {
    super.draw(rect)

    var hourToRemoveIndex = -1

    if isToday {
      let minute = currentTime.minute
      if minute > 39 {
        hourToRemoveIndex = currentTime.hour + 1
      } else if minute < 21 {
        hourToRemoveIndex = currentTime.hour
      }
    }

    let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    style.lineBreakMode = .byWordWrapping
    style.alignment = .right

    let attributes = [NSParagraphStyleAttributeName: style,
                      NSForegroundColorAttributeName: self.style.timeColor,
                      NSFontAttributeName: timeFont] as [String : Any]

    for (i, time) in times.enumerated() {
      let iFloat = CGFloat(i)
      let context = UIGraphicsGetCurrentContext()
      context!.interpolationQuality = .none
      context?.saveGState()
      context?.setStrokeColor(self.style.lineColor.cgColor)
      context?.setLineWidth(onePixel)
      context?.translateBy(x: 0, y: 0.5)
      let x: CGFloat = 53
      let y = verticalInset + iFloat * verticalDiff
      context?.beginPath()
      context?.move(to: CGPoint(x: x, y: y))
      context?.addLine(to: CGPoint(x: (bounds).width, y: y))
      context?.strokePath()
      context?.restoreGState()

      if i == hourToRemoveIndex { continue }

      let timeRect = CGRect(x: 2, y: iFloat * verticalDiff + verticalInset - 7,
                            width: leftInset - 8, height: fontSize + 2)

      let timeString = NSString(string: time)

      timeString.draw(in: timeRect, withAttributes: attributes)
    }
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    layoutEvents()
    layoutNowLine()
  }

  func layoutNowLine() {
    if !isToday {
      nowLine.alpha = 0
    } else {
      bringSubview(toFront: nowLine)
      nowLine.alpha = 1
      let size = CGSize(width: bounds.size.width, height: 20)
      let rect = CGRect(origin: CGPoint.zero, size: size)
      nowLine.date = currentTime
      nowLine.frame = rect
      nowLine.center.y = dateToY(currentTime)
    }
  }

  func layoutEvents() {
    if eventViews.isEmpty {return}

    let day = TimePeriod(beginning: date.dateOnly(),
                         chunk: TimeChunk(seconds: 0,
                                          minutes: 0,
                                          hours: 0,
                                          days: 1,
                                          weeks: 0,
                                          months: 0,
                                          years: 0))

    let validEvents = eventViews.filter {$0.datePeriod.overlaps(with: day)}
      .sorted {$0.datePeriod.beginning!.isEarlier(than: $1.datePeriod.beginning!)}

    var groupsOfEvents = [[EventView]]()
    var overlappingEvents = [EventView]()

    for event in validEvents {
      if overlappingEvents.isEmpty {
        overlappingEvents.append(event)
        continue
      }
      if overlappingEvents.last!.datePeriod.overlaps(with: event.datePeriod) {
        overlappingEvents.append(event)
        continue
      } else {
        groupsOfEvents.append(overlappingEvents)
        overlappingEvents.removeAll()
        overlappingEvents.append(event)
      }
    }

    groupsOfEvents.append(overlappingEvents)
    overlappingEvents.removeAll()

    for overlappingEvents in groupsOfEvents {
      let totalCount = CGFloat(overlappingEvents.count)
      for (index, event) in overlappingEvents.enumerated() {
        let startY = dateToY(event.datePeriod.beginning!)
        let endY = dateToY(event.datePeriod.end!)
        let floatIndex = CGFloat(index)
        let x = leftInset + floatIndex / totalCount * calendarWidth
        let equalWidth = calendarWidth / totalCount
        event.frame = CGRect(x: x, y: startY, width: equalWidth, height: endY - startY)
      }
    }
  }

  func prepareForReuse() {
    eventViews.forEach {$0.removeFromSuperview()}
  }

  // MARK: - Helpers

  fileprivate var onePixel: CGFloat {
    return 1 / UIScreen.main.scale
  }

  fileprivate func dateToY(_ date: Date) -> CGFloat {
    let hourY = CGFloat(date.hour) * verticalDiff + verticalInset
    let minuteY = CGFloat(date.minute) * verticalDiff / 60
    return hourY + minuteY
  }
}
