import UIKit
import DateToolsSwift
import DynamicColor

open class Event: EventDescriptor {
  public var datePeriod = TimePeriod()
  public var text = ""
  public var color = UIColor.blue {
    didSet {
      textColor = color.darkened(amount: 0.3)
      backgroundColor = UIColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 0.3)
    }
  }
  public var backgroundColor = UIColor()
  public var textColor = UIColor()
  public var frame = CGRect.zero
  public init() {}
}
