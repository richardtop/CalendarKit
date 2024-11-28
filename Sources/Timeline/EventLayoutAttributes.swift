import CoreGraphics
import Foundation
public final class EventLayoutAttributes : CustomStringConvertible {
    public let descriptor: EventDescriptor
    
    /// Ensures that events with very short time intervals are given a minimum height.
    /// This prevents events from being rendered too small, allowing text and content
    /// to be displayed properly within the event view.
    private let minimumEventHeight: CGFloat = TimelineLayoutAttributes.shared.veticalDifferenceBetweenHours / 2.0
    
    public var frame = CGRect.zero {
        didSet {
            if frame.height < minimumEventHeight {
                frame.size.height = minimumEventHeight
            }
        }
    }
    public init(_ descriptor: EventDescriptor) {
        self.descriptor = descriptor
    }
    public var description: String {
        return "\(descriptor.dateInterval.start.toHourMinuteSecondString())|\(descriptor.dateInterval.end.toHourMinuteSecondString())"
    }
}

private extension Date {
    func toHourMinuteSecondString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
}
