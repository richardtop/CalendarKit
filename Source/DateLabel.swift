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
    if self.selected {
      self.font = UIFont.boldSystemFontOfSize(self.fontSize)
      self.textColor = self.activeTextColor
      self.backgroundColor = self.today ? self.todayBackgroundColor : self.selectedBackgroundColor
    } else {
      let clr = self.weekend ? self.weekendTextColor : self.inactiveTextColor
      self.font = UIFont.systemFontOfSize(self.fontSize)
      self.textColor = self.today ? self.activeTextColor : clr
      self.backgroundColor = self.today ? self.todayBackgroundColor : self.inactiveBackgroundColor
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
