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
    public var startXs : [HorizontalPosition] = []
    public var endXs : [ HorizontalPosition] = []
    public init(_ descriptor: EventDescriptor) {
        self.descriptor = descriptor
    }
    
    // User-friendly description
    public var description: String {
        return "\(descriptor.dateInterval.start.toHourMinuteString())|\(descriptor.dateInterval.end.toHourMinuteString())"
    }
}

public struct HorizontalPosition {
    var x : CGFloat
    var overlappingCount : Int
    var positionInOverlappingGroup : Int
    func overlappingCountDividedPosition() -> Double { return Double(overlappingCount) / Double(positionInOverlappingGroup)}
    //smallest index in the longest group
    // smallest positionInOverlappingGroup with the biggest overlappingCount
}

func findOptimalStartX(from positions: [HorizontalPosition]) -> HorizontalPosition? {
    return positions.min { lhs, rhs in
        // Primary comparison: highest overlappingCount
        if lhs.overlappingCount != rhs.overlappingCount {
            return lhs.overlappingCount > rhs.overlappingCount
        }
        // Secondary comparison: lowest positionInOverlappingGroup
        return lhs.positionInOverlappingGroup < rhs.positionInOverlappingGroup
    }
}

func findOptimalEndX(from positions: [HorizontalPosition]) -> HorizontalPosition? {
    return positions.max { lhs, rhs in
        // Primary comparison: highest overlappingCount
        if lhs.overlappingCount != rhs.overlappingCount {
            return lhs.overlappingCount > rhs.overlappingCount
        }
        // Secondary comparison: lowest positionInOverlappingGroup
        return lhs.positionInOverlappingGroup < rhs.positionInOverlappingGroup
    }
}

extension Date {
    /// Converts the date to a string in "HH:mm" format using the device's time zone.
    func toHourMinuteString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current // Use the device's time zone
        return formatter.string(from: self)
    }
}
