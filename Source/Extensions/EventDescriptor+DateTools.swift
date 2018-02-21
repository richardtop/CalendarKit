import Foundation
import DateToolsSwift

/**
 A bridge between CalendarKit and underlying date processing library.
 Allows using any third-party library for the date processing,
 without exposing it to the client.
 */
extension EventDescriptor {
  var datePeriod: TimePeriod {
    return TimePeriod(beginning: startDate, end: endDate)
  }
}
