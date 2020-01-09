import UIKit

public enum DateStyle {
    ///Times should be shown in the 12 hour format
    case twelveHour
    
    ///Times should be shown in the 24 hour format
    case twentyFourHour
    
    ///Times should be shown according to the user's system preference.
    case system
}

public struct CalendarStyle {
  public var header = DayHeaderStyle()
  public var timeline = TimelineStyle()
  public init() {}
}

public struct DayHeaderStyle {
  public var daySymbols = DaySymbolsStyle()
  public var daySelector = DaySelectorStyle()
  public var swipeLabel = SwipeLabelStyle()
  public var backgroundColor = UIColor(white: 247/255, alpha: 1)
  public init() {}
}

public struct DaySelectorStyle {
  public var activeTextColor = UIColor.white
  public var selectedBackgroundColor = UIColor.black

  public var weekendTextColor = UIColor.gray
  public var inactiveTextColor = UIColor.black
  public var inactiveBackgroundColor = UIColor.clear

  public var todayInactiveTextColor = UIColor.red
  public var todayActiveTextColor = UIColor.white
  public var todayActiveBackgroundColor = UIColor.red
    
  public var font = UIFont.systemFont(ofSize: 18)
  public var todayFont = UIFont.boldSystemFont(ofSize: 18)
  
  public init() {}
}

public struct DaySymbolsStyle {
  public var weekendColor = UIColor.lightGray
  public var weekDayColor = UIColor.black
  public var font = UIFont.systemFont(ofSize: 10)
  public init() {}
}

public struct SwipeLabelStyle {
  public var textColor = UIColor.black
  public var font = UIFont.systemFont(ofSize: 15)
  public init() {}
}

public struct TimelineStyle {
  public var allDayStyle = AllDayViewStyle()
  public var timeIndicator = CurrentTimeIndicatorStyle()
  public var timeColor = UIColor.lightGray
  public var lineColor = UIColor.lightGray
  public var backgroundColor = UIColor.white
  public var font = UIFont.boldSystemFont(ofSize: 11)
  public var dateStyle : DateStyle = .system
  public var eventsWillOverlap: Bool = false
  public var splitMinuteInterval: Int = 15
  public var verticalDiff: CGFloat = 50
  public var verticalInset: CGFloat = 10
  public var leftInset: CGFloat = 53
  public var eventGap: CGFloat = 0
  public init() {}
}

public struct CurrentTimeIndicatorStyle {
  public var color = UIColor.red
  public var font = UIFont.systemFont(ofSize: 11)
  public var dateStyle : DateStyle = .system
  public init() {}
}

public struct AllDayViewStyle {
  public var backgroundColor: UIColor = UIColor.lightGray
  public var allDayFont = UIFont.systemFont(ofSize: 12.0)
  public var allDayColor: UIColor = UIColor.black
  public init() {}
}
