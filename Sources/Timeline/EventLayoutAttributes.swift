import CoreGraphics

public final class EventLayoutAttributes {
    public let descriptor: EventDescriptor
    
    /// Ensures that events with very short time intervals are given a minimum height.
    /// This prevents events from being rendered too small, allowing text and content
    /// to be displayed properly within the event view.
    private let minimumEventHeight: CGFloat = 35.0
    
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
}
