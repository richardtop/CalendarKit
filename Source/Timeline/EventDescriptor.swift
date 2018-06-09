import Foundation

public protocol EventDescriptor {
  var startDate: Date {get}
  var endDate: Date {get}
  var isAllDay: Bool {get}
  var text: String {get}
  var attributedText: NSAttributedString? {get}
  var font : UIFont {get}
  var color: UIColor {get}
  var textColor: UIColor {get}
  var backgroundColor: UIColor {get}
}
