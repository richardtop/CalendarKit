import Foundation

extension NSDate {
  func dateOnly() -> NSDate {
    return NSDate(year: year(), month: month(), day: day())
  }
}
