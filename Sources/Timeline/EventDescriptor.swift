import Foundation
import UIKit

public protocol EventDescriptor: AnyObject {
  var dateInterval: DateInterval {get set}
  var isAllDay: Bool {get}
  var isPrivate: Bool {get}
  var text: String {get}
  var location: String? {get}
  var attributedText: NSAttributedString? {get}
  var lineBreakMode: NSLineBreakMode? {get}
  var font : UIFont {get}
  var color: UIColor {get}
  var textColor: UIColor {get}
  var backgroundColor: UIColor {get}
  var editedEvent: EventDescriptor? {get set}
  var responseType: Int { get }
  var isCancelledAppointment: Bool { get }
  func makeEditable() -> Self
  func commitEditing()
}

public enum CalendarResponse: Int {
    case unknown
    case organizer
    case tentative
    case accept
    case decline
    case noResponseReceived
}
