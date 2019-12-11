import Foundation

final class SnapTo15MinuteIntervals: EventEditingSnappingBehavior {
  private let calendar: Calendar

  init(_ calendar: Calendar) {
    self.calendar = calendar
  }

  func nearestDate(to date: Date) -> Date {
    let unit: Double = (60 / 4) / 2
    var accHour = Int(accentedHour(for: date))
    let minute = Double(component(component: .minute, from: date))
    if (60 - unit)...59 ~= minute {
      accHour += 1
    }
    return calendar.date(bySettingHour: accHour,
                         minute: accentedMinute(for: date),
                         second: 0,
                         of: date)!
  }

  func accentedHour(for date: Date) -> Int {
    return Int(component(component: .hour, from: date))
  }

  func accentedMinute(for date: Date) -> Int {
    let accentedMinute = Double(component(component: .minute, from: date))
    return snapTo15Minute(accentedMinute)
  }
  
  private func snapTo15Minute(_ number: Double) -> Int {
    let value = 15 * Int(round(number / 15.0))
    return value < 60 ? value : 0
  }
  
  private func component(component: Calendar.Component, from date: Date) -> Int {
    return calendar.component(component, from: date)
  }
}
