import Foundation

public protocol EventDataSource: class {
  func eventsForDate(_ date: Date) -> [EventDescriptor]
}
