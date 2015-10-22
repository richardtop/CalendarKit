import UIKit

class DateLabel: UILabel {

  var fontSize: CGFloat = 18

  var date: NSDate! {
    didSet {
      text = String(date.day())
      updateState()
    }
  }

  var selected: Bool = false {
    didSet {
      animate()
    }
  }

  //TODO: these vars are to introduce factory later

  var activeTextColor = UIColor.whiteColor()
  var weekendTextColor = UIColor.grayColor()
  var inactiveTextColor = UIColor.blackColor()

  var todayColor = UIColor.redColor()
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
  }

  func updateState() {
    let today = date.isToday()
    if selected {
      font = UIFont.boldSystemFontOfSize(fontSize)
      textColor = activeTextColor
      backgroundColor = today ? todayColor : selectedBackgroundColor
    } else {
      let clr = date.isWeekend() ? weekendTextColor : inactiveTextColor
      font = UIFont.systemFontOfSize(fontSize)
      textColor = today ? todayColor : clr
      backgroundColor = inactiveBackgroundColor
    }
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
