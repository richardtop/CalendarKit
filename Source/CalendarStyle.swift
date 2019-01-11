

public enum DateStyle {
    ///Times should be shown in the 12 hour format
    case twelveHour
    
    ///Times should be shown in the 24 hour format
    case twentyFourHour
    
    ///Times should be shown according to the user's system preference.
    case system
}

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
    
  public var font = UIFont.systemFont(ofSize: 18)
  public var todayFont = UIFont.boldSystemFont(ofSize: 18)

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
    copy.font = font
    copy.todayFont = todayFont
    return copy
  }
}

public class DaySymbolsStyle: NSCopying {
  public var weekendColor = UIColor.lightGray
  public var weekDayColor = UIColor.black
  public var font = UIFont.systemFont(ofSize: 10)
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = DaySymbolsStyle()
    copy.weekendColor = weekendColor
    copy.weekDayColor = weekDayColor
    copy.font = font
    return copy
  }
}

public class SwipeLabelStyle: NSCopying {
  public var textColor = UIColor.black
  public var font = UIFont.systemFont(ofSize: 15)
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = SwipeLabelStyle()
    copy.textColor = textColor
    copy.font = font
    return copy
  }
}

public class TimelineStyle: NSCopying {
  public var timeIndicator = CurrentTimeIndicatorStyle()
  public var timeColor = UIColor.lightGray
  public var lineColor = UIColor.lightGray
  public var backgroundColor = UIColor.white
  public var font = UIFont.boldSystemFont(ofSize: 11)
  public var dateStyle : DateStyle = .system
  public var eventsWillOverlap: Bool = false
  public var splitMinuteInterval: Int = 15
  public var verticalDiff: CGFloat = 45
  public var verticalInset: CGFloat = 10
  public var leftInset: CGFloat = 53
  public var eventGap: CGFloat = 0
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = TimelineStyle()
    copy.timeIndicator = timeIndicator.copy() as! CurrentTimeIndicatorStyle
    copy.timeColor = timeColor
    copy.lineColor = lineColor
    copy.backgroundColor = backgroundColor
    copy.font = font
    copy.dateStyle = dateStyle
    copy.eventsWillOverlap = eventsWillOverlap
    copy.splitMinuteInterval = splitMinuteInterval
    copy.verticalDiff = verticalDiff
    copy.verticalInset = verticalInset
    copy.eventGap = eventGap
    return copy
  }
}

public class CurrentTimeIndicatorStyle: NSCopying {
  public var color = UIColor.red
  public var font = UIFont.systemFont(ofSize: 11)
  public var dateStyle : DateStyle = .system
  public init() {}
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = CurrentTimeIndicatorStyle()
    copy.color = color
    copy.font = font
    copy.dateStyle = dateStyle
    return copy
  }
}

public class AllDayStyle: NSCopying {
  public var backgroundColor: UIColor = UIColor.lightGray
  public var allDayFont = UIFont.systemFont(ofSize: 12.0)
  public var allDayColor: UIColor = UIColor.black
  
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = AllDayStyle()
    copy.allDayColor = allDayColor
    copy.backgroundColor = backgroundColor
    copy.allDayFont = allDayFont
    
    return copy
  }
}
