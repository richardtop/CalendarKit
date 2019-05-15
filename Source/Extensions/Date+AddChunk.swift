import Foundation
import DateToolsSwift

extension Date {
  // MARK: - Addition / Subtractions

  /**
   *  # Add (TimeChunk to Date)
   *  Increase a date by the value of a given `TimeChunk`.
   *
   *  - parameter chunk: The amount to increase the date by (ex. 2.days, 4.years, etc.)
   *
   *  - returns: A date with components increased by the values of the
   *  corresponding `TimeChunk` variables
   */
  public func add(_ chunk: TimeChunk, calendar: Calendar) -> Date {
    var components = DateComponents()
    components.year = chunk.years
    components.month = chunk.months
    components.day = chunk.days + (chunk.weeks*7)
    components.hour = chunk.hours
    components.minute = chunk.minutes
    components.second = chunk.seconds
    return calendar.date(byAdding: components, to: self)!
  }

  /**
   *  # Subtract (TimeChunk from Date)
   *  Decrease a date by the value of a given `TimeChunk`.
   *
   *  - parameter chunk: The amount to decrease the date by (ex. 2.days, 4.years, etc.)
   *
   *  - returns: A date with components decreased by the values of the
   *  corresponding `TimeChunk` variables
   */
  public func subtract(_ chunk: TimeChunk, calendar: Calendar) -> Date {
    var components = DateComponents()
    components.year = -chunk.years
    components.month = -chunk.months
    components.day = -(chunk.days + (chunk.weeks*7))
    components.hour = -chunk.hours
    components.minute = -chunk.minutes
    components.second = -chunk.seconds
    return calendar.date(byAdding: components, to: self)!
  }
}
