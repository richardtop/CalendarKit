import CalendarKit

struct StyleGenerator {
  static func defaultStyle() -> CalendarStyle {
    return CalendarStyle()
  }

  static func darkStyle() -> CalendarStyle {
    let black = UIColor.black
    let darkGray = UIColor(white: 0.15, alpha: 1)
    let lightGray = UIColor.lightGray
    let white = UIColor.white

    let selector = DaySelectorStyle()
    selector.activeTextColor = black
    selector.inactiveTextColor = white
    selector.selectedBackgroundColor = white

    let daySymbols = DaySymbolsStyle()
    daySymbols.weekDayColor = white
    daySymbols.weekendColor = lightGray

    let swipeLabel = SwipeLabelStyle()
    swipeLabel.textColor = white

    let header = DayHeaderStyle()
    header.daySelector = selector
    header.daySymbols = daySymbols
    header.swipeLabel = swipeLabel
    header.backgroundColor = black

    let timeline = TimelineStyle()
    timeline.lineColor = lightGray
    timeline.timeColor = lightGray
    timeline.backgroundColor = black
    timeline.allDayStyle.backgroundColor = darkGray
    timeline.allDayStyle.allDayColor = white

    let style = CalendarStyle()
    style.header = header
    style.timeline = timeline

    return style
  }
}
