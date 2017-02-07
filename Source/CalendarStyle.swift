public class CalendarStyle {
  public var header = DayHeaderStyle()
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
