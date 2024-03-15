import Foundation
import UIKit

public protocol EventDescriptor: AnyObject {
    var dateInterval: DateInterval {get set}
    var isAllDay: Bool {get}
    var text: String {get}
    var attributedText: NSAttributedString? {get}
    var lineBreakMode: NSLineBreakMode? {get}
    var font : UIFont {get}
    var color: UIColor {get}
    var textColor: UIColor {get}
    var backgroundColor: UIColor {get}
    var editedEvent: EventDescriptor? {get set}
    var border: CAShapeLayer? {get}
    func makeEditable() -> Self
    func commitEditing()
}
