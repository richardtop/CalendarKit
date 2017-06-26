import UIKit
import DateToolsSwift

open class Event: EventDescriptor {
  public var datePeriod = TimePeriod()
  public var text = ""
  public var color = UIColor.blue {
    didSet {
      backgroundColor = color.withAlphaComponent(0.3)
      var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
      textColor = UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a)
    }
  }
  public var backgroundColor = UIColor.blue.withAlphaComponent(0.3)
  public var textColor = UIColor.black
  public var frame = CGRect.zero
  public var userInfo: Any?
  public init() {}
}
