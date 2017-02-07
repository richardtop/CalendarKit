public class CalendarStyle {
  public var header = HeaderStyle()
  public init() {}
}

public class HeaderStyle {
  public var daySymbols = DaySymbolsStyle()
  public var daySelector = DaySelectorStyle()
  public var swipeLabel = SwipeLabelStyle()
  public init() {}
}

public class DaySelectorStyle {
  public var activeTextColor = UIColor.white
  public var weekendTextColor = UIColor.gray
  public var inactiveTextColor = UIColor.black

  public var selectedBackgroundColor = UIColor.black
  public var inactiveBackgroundColor = UIColor.clear
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
