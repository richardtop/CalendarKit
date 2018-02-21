import Foundation
import DateToolsSwift

extension EventDescriptor {
  var datePeriod: TimePeriod {
    return TimePeriod(beginning: startDate, end: endDate)
  }
}
