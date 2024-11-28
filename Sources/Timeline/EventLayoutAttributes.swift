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
    
    public var startY : CGFloat = 0.0
    public var endY : CGFloat = 0.0
    public var xAxisCandidates : [horizontalBounds] = []
    
    public var dio: DateInterval
    public init(_ descriptor: EventDescriptor) {
        self.descriptor = descriptor
        self.dio = DateInterval(start: descriptor.dateInterval.start, end: descriptor.dateInterval.end)
    }
    
    // User-friendly description
    public var description: String {
        return "\(dio.start.toHourMinuteString())|\(dio.end.toHourMinuteString())"
    }
}

public struct horizontalBounds {
    var startX : CGFloat
    var endX : CGFloat
}

private extension Date {
    func toHourMinuteString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
}
