public class CalendarStyle: NSCopying {
  public var header = DayHeaderStyle()
  public var timeline = TimelineStyle()
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = CalendarStyle()
    copy.header = header.copy() as! DayHeaderStyle
    copy.timeline = timeline.copy() as! TimelineStyle
    return copy
  }
}

public protocol DayHeaderStyleProtocol {
  func updateStyle(_ newStyle: DayHeaderStyle)
}

public class DayHeaderStyle: NSCopying {
  public var daySymbols = DaySymbolsStyle()
  public var daySelector = DaySelectorStyle()
  public var swipeLabel = SwipeLabelStyle()
  public var backgroundColor = UIColor(white: 247/255, alpha: 1)
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = DayHeaderStyle()
    copy.daySymbols = daySymbols.copy() as! DaySymbolsStyle
    copy.daySelector = daySelector.copy() as! DaySelectorStyle
    copy.swipeLabel = swipeLabel.copy() as! SwipeLabelStyle
    copy.backgroundColor = backgroundColor
    return copy
  }
}

public class DaySelectorStyle: NSCopying {
  public var activeTextColor = UIColor.white
  public var selectedBackgroundColor = UIColor.black

  public var weekendTextColor = UIColor.gray
  public var inactiveTextColor = UIColor.black
  public var inactiveBackgroundColor = UIColor.clear

  public var todayInactiveTextColor = UIColor.red
  public var todayActiveBackgroundColor = UIColor.red

  public init() {}

  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = DaySelectorStyle()
    copy.activeTextColor = activeTextColor
    copy.selectedBackgroundColor = selectedBackgroundColor
    copy.weekendTextColor = weekendTextColor
    copy.inactiveTextColor = inactiveTextColor
    copy.inactiveBackgroundColor = inactiveBackgroundColor
    copy.todayInactiveTextColor = todayInactiveTextColor
    copy.todayActiveBackgroundColor = todayActiveBackgroundColor
    return copy
  }
}

public class DaySymbolsStyle: NSCopying {
  public var weekendColor = UIColor.lightGray
  public var weekDayColor = UIColor.black
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = DaySymbolsStyle()
    copy.weekendColor = weekendColor
    copy.weekDayColor = weekDayColor
    return copy
  }
}

public class SwipeLabelStyle: NSCopying {
  public var textColor = UIColor.black
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = SwipeLabelStyle()
    copy.textColor = textColor
    return copy
  }
}

public class TimelineStyle: NSCopying {
  public var timeIndicator = CurrentTimeIndicatorStyle()
  public var timeColor = UIColor.lightGray
  public var lineColor = UIColor.lightGray
  public var backgroundColor = UIColor.white
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = TimelineStyle()
    copy.timeIndicator = timeIndicator.copy() as! CurrentTimeIndicatorStyle
    copy.timeColor = timeColor
    copy.lineColor = lineColor
    copy.backgroundColor = backgroundColor
    return copy
  }
}

public class CurrentTimeIndicatorStyle: NSCopying {
  public var color = UIColor.red
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = CurrentTimeIndicatorStyle()
    copy.color = color
    return copy
  }
}
