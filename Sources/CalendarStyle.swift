import Foundation
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
  public var backgroundColor = SystemColors.secondarySystemBackground
  public init() {}
}

public struct DaySelectorStyle {
  public var activeTextColor = SystemColors.systemBackground
  public var selectedBackgroundColor = SystemColors.label

  public var weekendTextColor = SystemColors.secondaryLabel
  public var inactiveTextColor = SystemColors.label
  public var inactiveBackgroundColor = UIColor.clear

  public var todayInactiveTextColor = SystemColors.systemRed
  public var todayActiveTextColor = UIColor.white
  public var todayActiveBackgroundColor = SystemColors.systemRed
    
  public var font = UIFont.systemFont(ofSize: 18)
  public var todayFont = UIFont.boldSystemFont(ofSize: 18)
  
  public init() {}
}

public struct DaySymbolsStyle {
  public var weekendColor = SystemColors.secondaryLabel
  public var weekDayColor = SystemColors.label
  public var font = UIFont.systemFont(ofSize: 10)
  public init() {}
}

public struct SwipeLabelStyle {
  public var textColor = SystemColors.label
  public var font = UIFont.systemFont(ofSize: 15)
  public init() {}
}

public struct TimelineStyle {
  public var allDayStyle = AllDayViewStyle()
  public var timeIndicator = CurrentTimeIndicatorStyle()
  public var timeColor = SystemColors.secondaryLabel
  public var separatorColor = SystemColors.systemSeparator
  public var backgroundColor = SystemColors.systemBackground
  public var font = UIFont.boldSystemFont(ofSize: 11)
  public var dateStyle : DateStyle = .system
  public var eventsWillOverlap: Bool = false
  public var minimumEventDurationInMinutesWhileEditing: Int = 30
  public var splitMinuteInterval: Int = 15
  public var verticalDiff: CGFloat = 50
  public var verticalInset: CGFloat = 10
  public var leadingInset: CGFloat = 53
  public var eventGap: CGFloat = 0
  public init() {}
}

public struct CurrentTimeIndicatorStyle {
  public var color = SystemColors.systemRed
  public var font = UIFont.systemFont(ofSize: 11)
  public var dateStyle : DateStyle = .system
  public init() {}
}

public struct AllDayViewStyle {
  public var backgroundColor: UIColor = SystemColors.systemGray4
  public var allDayFont = UIFont.systemFont(ofSize: 12.0)
  public var allDayColor: UIColor = SystemColors.label
  public init() {}
}
