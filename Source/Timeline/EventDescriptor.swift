import Foundation
import UIKit

public protocol EventDescriptor: AnyObject {
    var priority: NSAttributedString? {get set}
    var priorityColor: UIColor? {get set}
    var categoryColor: UIColor? {get set}
    var categoryText: NSAttributedString? {get set}
    var subtitleText: NSAttributedString? {get set}
    var taskId: String? {get set}
    var id: String {get set}
    var isChecked: Bool {get set}
  var startDate: Date {get set}
  var endDate: Date {get set}
  var isAllDay: Bool {get}
  var text: String {get}
  var attributedText: NSAttributedString? {get}
  var lineBreakMode: NSLineBreakMode? {get}
  var font : UIFont {get}
  var color: UIColor {get}
  var textColor: UIColor {get}
  var backgroundColor: UIColor {get}
  var editedEvent: EventDescriptor? {get set}
  func makeEditable() -> Self
  func commitEditing()
}
