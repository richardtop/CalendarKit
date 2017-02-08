import CalendarKit
import DynamicColor

struct StyleGenerator {
  static func defaultStyle() -> CalendarStyle {
    return CalendarStyle()
  }

  static func darkStyle() -> CalendarStyle {
    let orange = UIColor.orange
    let dark = UIColor(hexString: "1A1A1A")
    let light = UIColor.lightGray
    let white = UIColor.white

    let selector = DaySelectorStyle()
    selector.activeTextColor = white
    selector.inactiveTextColor = white
    selector.selectedBackgroundColor = light
    selector.todayActiveBackgroundColor = orange
    selector.todayInactiveTextColor = orange

    let daySymbols = DaySymbolsStyle()
    daySymbols.weekDayColor = white
    daySymbols.weekendColor = light

    let swipeLabel = SwipeLabelStyle()
    swipeLabel.textColor = white

    let header = DayHeaderStyle()
    header.daySelector = selector
    header.daySymbols = daySymbols
    header.swipeLabel = swipeLabel
    header.backgroundColor = dark

    let timeline = TimelineStyle()
    timeline.timeIndicator.color = orange
    timeline.lineColor = light
    timeline.timeColor = light
    timeline.backgroundColor = dark

    let style = CalendarStyle()
    style.header = header
    style.timeline = timeline

    return style
  }
}
