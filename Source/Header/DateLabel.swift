import UIKit

class DateLabel: UILabel {

  var fontSize: CGFloat = 18

  var date: NSDate! {
    didSet {
      text = String(date.day())
    }
  }

  //TODO: refactor TODAY to computed property

  var today: Bool = false
  var selected: Bool = false {
    didSet {
      animate()
    }
  }

  var weekend: Bool = false {
    didSet {
      updateState()
    }
  }

  //TODO: these vars are to introduce factory later

  var activeTextColor = UIColor.whiteColor()
  var weekendTextColor = UIColor.grayColor()
  var inactiveTextColor = UIColor.blackColor()

  var todayBackgroundColor = UIColor.redColor()
  var selectedBackgroundColor = UIColor.blackColor()
  var inactiveBackgroundColor = UIColor.clearColor()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    userInteractionEnabled = true
    textAlignment = .Center
    clipsToBounds = true
    updateState()
  }

  func updateState() {
    if selected {
      font = UIFont.boldSystemFontOfSize(fontSize)
      textColor = activeTextColor
      backgroundColor = today ? todayBackgroundColor : selectedBackgroundColor
    } else {
      let clr = weekend ? weekendTextColor : inactiveTextColor
      font = UIFont.systemFontOfSize(fontSize)
      textColor = today ? activeTextColor : clr
      backgroundColor = today ? todayBackgroundColor : inactiveBackgroundColor
    }
    tag = today ? 1 : 0
  }

  func animate(){
    UIView.transitionWithView(self, duration: 0.3,
      options: .TransitionCrossDissolve,
      animations: { _ in
        self.updateState()
      }, completion: nil)
  }

  override func layoutSubviews() {
    layer.cornerRadius = bounds.height / 2
  }
}
