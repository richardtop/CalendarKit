public class CalendarStyle {
  public var header = DayHeaderStyle()
  public var timeline = TimelineStyle()
  public init() {}
}

public class DayHeaderStyle {
  public var daySymbols = DaySymbolsStyle()
  public var daySelector = DaySelectorStyle()
  public var swipeLabel = SwipeLabelStyle()
  public var backgroundColor = UIColor(white: 247/255, alpha: 1)
  public init() {}
}

public class DaySelectorStyle {
  public var activeTextColor = UIColor.white
  public var selectedBackgroundColor = UIColor.black

  public var weekendTextColor = UIColor.gray
  public var inactiveTextColor = UIColor.black
  public var inactiveBackgroundColor = UIColor.clear

  public var todayInactiveTextColor = UIColor.red
  public var todayActiveBackgroundColor = UIColor.red

  public init() {}
}

public class DaySymbolsStyle {
  public var weekendColor = UIColor.lightGray
  public var weekDayColor = UIColor.black
  public init() {}
}

public class SwipeLabelStyle {
  public var textColor = UIColor.black
  public init() {}
}

public class TimelineStyle {
  public var timeIndicator = CurrentTimeIndicatorStyle()
  public var timeColor = UIColor.lightGray
  public var lineColor = UIColor.lightGray
  public var backgroundColor = UIColor.white
  public var timeFormat = TimelineTimeFormat.system
  public var density = CalendarDensity.regular.rawValue
  public init() {}
}

public class CurrentTimeIndicatorStyle {
  public var color = UIColor.red
  public init() {}
}

public enum TimelineTimeFormat {
  case twentyFourHour, twelveHour, system
}

public enum CalendarDensity: CGFloat {
  case compact = 30.0
  case regular = 45.0
  case low = 100.0
  case veryLow = 140.0
}
