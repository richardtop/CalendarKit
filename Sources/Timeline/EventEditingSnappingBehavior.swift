import Foundation

public protocol EventEditingSnappingBehavior {
  var calendar: Calendar {get set}
  func nearestDate(to date: Date) -> Date
  func accentedHour(for date: Date) -> Int
  func accentedMinute(for date: Date) -> Int
}
