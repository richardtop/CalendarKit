import Foundation

final class TimelineEditingSnapBehaviorDefault: EventEditingSnappingBehavior {
  private let calendar: Calendar
  private let unit: Double = (60 / 4) / 2

  init(_ calendar: Calendar) {
    self.calendar = calendar
  }
  
  func nearestDate(to date: Date) -> Date {
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
    var accentedMinute = Double(component(component: .minute, from: date))
    guard unit...(60 - unit) ~= accentedMinute else {
      return 0
    }

    if (15 - unit)...(15 + unit) ~= accentedMinute {
      accentedMinute = 15
    } else if (30 - unit)...(30 + unit) ~= accentedMinute {
      accentedMinute = 30
    } else {
      accentedMinute = 45
    }
    return Int(accentedMinute)
  }
  
  private func component(component: Calendar.Component, from date: Date) -> Int {
    return calendar.component(component, from: date)
  }
}
