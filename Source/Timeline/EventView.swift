import UIKit
import DateToolsSwift
import Neon

protocol EventViewDelegate: class {
  func eventViewDidTap(_ eventView: EventView)
  func eventViewDidLongPress(_ eventview: EventView)
}

public protocol EventDescriptor: class {
  var datePeriod: TimePeriod {get}
  var text: String {get}
  var color: UIColor {get}
  var textColor: UIColor {get}
  var backgroundColor: UIColor {get}
  var frame: CGRect {get set}
}

open class EventView: UIView {

  weak var delegate: EventViewDelegate?
  public var descriptor: EventDescriptor?

  public var color = UIColor()

  var contentHeight: CGFloat {
    return textView.height
  }

  public var userInfo: Any?

  lazy var textView: UITextView = {
    let view = UITextView()
    view.font = UIFont.boldSystemFont(ofSize: 12)
    view.isUserInteractionEnabled = false
    view.backgroundColor = .clear
    return view
  }()

  lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
  lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    clipsToBounds = true
    [tapGestureRecognizer, longPressGestureRecognizer].forEach {addGestureRecognizer($0)}

    color = tintColor
    addSubview(textView)
  }

  func updateWithDescriptor(event: EventDescriptor) {
    descriptor = event
    textView.text = event.text
    textView.textColor = event.textColor
    backgroundColor = event.backgroundColor
    color = event.color
    setNeedsDisplay()
    setNeedsLayout()
  }

  func tap() {
    delegate?.eventViewDidTap(self)
  }

  func longPress() {
    delegate?.eventViewDidLongPress(self)
  }

  override open func draw(_ rect: CGRect) {
    super.draw(rect)
    let context = UIGraphicsGetCurrentContext()
    context!.interpolationQuality = .none
    context?.saveGState()
    context?.setStrokeColor(color.cgColor)
    context?.setLineWidth(3)
    context?.translateBy(x: 0, y: 0.5)
    let x: CGFloat = 0
    let y: CGFloat = 0
    context?.beginPath()
    context?.move(to: CGPoint(x: x, y: y))
    context?.addLine(to: CGPoint(x: x, y: (bounds).height))
    context?.strokePath()
    context?.restoreGState()
  }

  override open func layoutSubviews() {
    super.layoutSubviews()
    textView.fillSuperview()
  }
}
