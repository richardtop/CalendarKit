import Foundation

extension Date {
  func dateOnly() -> Date {
    return Date(year: year, month: month, day: day)
  }
}
