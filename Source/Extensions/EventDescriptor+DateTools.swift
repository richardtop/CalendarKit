import Foundation

/**
 A bridge between CalendarKit and underlying date processing library.
 Allows using any third-party library for the date processing,
 without exposing it to the client.
 */
extension EventDescriptor {
  var datePeriod: ClosedRange<Date> {
    return startDate ... endDate
  }
}
