import Foundation

public protocol EventDataSource: AnyObject {
  func eventsForDate(_ date: Date, presentation: TimelinePresentation) -> [EventDescriptor]
}
