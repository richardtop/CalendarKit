#if os(iOS)
import Foundation
import UIKit

public protocol EventDescriptor: AnyObject {
  var startDate: Date {get set}
  var endDate: Date {get set}
  var isAllDay: Bool {get set} // TODO: should we return this to read-only?
  var text: String {get set} // TODO: should we return this to read-only?
  var attributedText: NSAttributedString? {get}
  var font : UIFont {get}
  var color: UIColor {get set} // TODO: should we return this to read-only?
  var textColor: UIColor {get set} // TODO: should we return this to read-only?
  var backgroundColor: UIColor {get set} // TODO: should we return this to read-only?
  var editedEvent: EventDescriptor? {get set}
  func makeEditable() -> Self
  func commitEditing()
}
#endif
