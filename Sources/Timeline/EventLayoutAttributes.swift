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
    public var xAxisCandidates : [HorizontalPosition] = []
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
    var maxX : CGFloat
    var width : CGFloat
    var overlappingCount : Int
    var positionInOverlappingGroup : Int
    func overlappingCountDividedPosition() -> Double { return Double(overlappingCount) / Double(positionInOverlappingGroup)}
    func positionDividedOverlappingCount() -> Double { return Double(positionInOverlappingGroup) / Double(overlappingCount)}
}
func findOptimalWidth(from positions: [HorizontalPosition]) -> HorizontalPosition? {
    
     let appearancesWhereItsonTheBeginningInOverlappingGroup = positions.filter { h in
         h.positionInOverlappingGroup == 1
      }
     
     return appearancesWhereItsonTheBeginningInOverlappingGroup.min { lhs, rhs in
            return lhs.overlappingCount > rhs.overlappingCount
    }
}
func findOptimalStartX(index: Int, sortedEvents: [EventLayoutAttributes]) -> HorizontalPosition? {
    if index == 0 {
        return sortedEvents[0].xAxisCandidates.min { lhs, rhs in
            return lhs.x < rhs.x
        }
    }
    
    return sortedEvents[index - 1].xAxisCandidates.min { lhs, rhs in
        return lhs.maxX >= rhs.maxX
    }
    
    /*let appearancesWhereTheresMoreToTheRightInOverlappingGroup = positions.filter { h in
        h.positionInOverlappingGroup < h.overlappingCount
     }
     
     let appearancesWhereItsonTheBeginningInOverlappingGroup = positions.filter { h in
         h.positionInOverlappingGroup == 1
      }
     
     let appearancesWhereItsonTheMiddleInOverlappingGroup = positions.filter { h in
         h.positionInOverlappingGroup != 1 && h.positionInOverlappingGroup != h.overlappingCount
      }
     
     let appearancesWhereItsonTheEndInOverlappingGroup = positions.filter { h in
        h.positionInOverlappingGroup == h.overlappingCount
      }
     
     
    let appearedAtTheBeginning = !appearancesWhereItsonTheBeginningInOverlappingGroup.isEmpty
    if appearedAtTheBeginning {
        return positions.min { lhs, rhs in
            lhs.x > rhs.x
        }
    }
    
     let appearedAtTheMiddle = !appearancesWhereItsonTheMiddleInOverlappingGroup.isEmpty
     if appearedAtTheMiddle {
         return positions.min { lhs, rhs in
             lhs.overlappingCountDividedPosition() > rhs.overlappingCountDividedPosition()
         }
     }
     
    let appearedAtTheEnd = !appearancesWhereItsonTheEndInOverlappingGroup.isEmpty
    if appearedAtTheEnd {
        return appearancesWhereItsonTheEndInOverlappingGroup.min { lhs, rhs in
            lhs.maxX > rhs.maxX
        }
    }*/
   
     ///NOTUSED
}




//lowest position in the longest overlapping
func findOptimalEndX(from positions: [HorizontalPosition]) -> HorizontalPosition? {
    
   let appearancesWhereTheresMoreToTheRightInOverlappingGroup = positions.filter { h in
       h.positionInOverlappingGroup < h.overlappingCount
    }
    
    let appearancesWhereItsonTheBeginningInOverlappingGroup = positions.filter { h in
        h.positionInOverlappingGroup == 1
     }
    
    let appearancesWhereItsonTheMiddleInOverlappingGroup = positions.filter { h in
        h.positionInOverlappingGroup != 1 && h.positionInOverlappingGroup != h.overlappingCount
     }
    
    let appearancesWhereItsonTheEndInOverlappingGroup = positions.filter { h in
       h.positionInOverlappingGroup == h.overlappingCount
     }
    
    
    let appearedAtTheEnd = !appearancesWhereItsonTheEndInOverlappingGroup.isEmpty
    if appearedAtTheEnd {
        return positions.min { lhs, rhs in
            lhs.maxX > rhs.maxX
        }
    }
  
    let appearedAtTheMiddle = !appearancesWhereItsonTheMiddleInOverlappingGroup.isEmpty
    if appearedAtTheMiddle {
        return positions.min { lhs, rhs in
            lhs.overlappingCountDividedPosition() > rhs.overlappingCountDividedPosition()
        }
    }
    
    let appearedAtTheBeginning = !appearancesWhereItsonTheBeginningInOverlappingGroup.isEmpty
    if appearedAtTheBeginning {
        return appearancesWhereItsonTheBeginningInOverlappingGroup.min { lhs, rhs in
            lhs.overlappingCount > rhs.overlappingCount
        }
    }
    
    
    ////////////////NOTUSED//////////
    let appearsOnlyAtTheEnd = !appearancesWhereItsonTheEndInOverlappingGroup.isEmpty && appearancesWhereItsonTheMiddleInOverlappingGroup.isEmpty && appearancesWhereItsonTheBeginningInOverlappingGroup.isEmpty
    
    /*if appearsOnlyAtTheEnd {
        return appearancesWhereItsonTheEndInOverlappingGroup.min { lhs, rhs in
            lhs.maxX < rhs.maxX
        }
    }*/
    
    let appearsOnlyAtTheBeginning = !appearancesWhereItsonTheBeginningInOverlappingGroup.isEmpty && appearancesWhereItsonTheMiddleInOverlappingGroup.isEmpty && appearancesWhereItsonTheEndInOverlappingGroup.isEmpty
    
   
    
    /*if appearsOnlyAtTheBeginning {
        return appearancesWhereItsonTheBeginningInOverlappingGroup.min { lhs, rhs in
            lhs.overlappingCount > rhs.overlappingCount
        }
    }*/
    
    if !appearancesWhereItsonTheBeginningInOverlappingGroup.isEmpty {
        return appearancesWhereItsonTheBeginningInOverlappingGroup.min { lhs, rhs in
            lhs.overlappingCount > rhs.overlappingCount
        }
    }
    if appearancesWhereTheresMoreToTheRightInOverlappingGroup.isEmpty {
        return positions.min { lhs, rhs in
            lhs.maxX < rhs.maxX
        }
    } else {
        return appearancesWhereTheresMoreToTheRightInOverlappingGroup.min { lhs, rhs in
            lhs.overlappingCountDividedPosition() > rhs.overlappingCountDividedPosition()
        }
    }
    return nil
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
