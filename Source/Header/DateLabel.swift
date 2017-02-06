import UIKit
import DateToolsSwift

class DateLabel: UILabel {

  var fontSize: CGFloat = 18

  var date: Date! {
    didSet {
      text = String(date.day)
      updateState()
    }
  }

  var selected: Bool = false {
    didSet {
      animate()
    }
  }

  //TODO: these vars are to introduce factory later

  var activeTextColor = UIColor.white
  var weekendTextColor = UIColor.gray
  var inactiveTextColor = UIColor.black

  var selectedBackgroundColor = UIColor.black
  var inactiveBackgroundColor = UIColor.clear

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    isUserInteractionEnabled = true
    textAlignment = .center
    clipsToBounds = true
  }

  func updateState() {
    let today = date.isToday
    if selected {
      font = UIFont.boldSystemFont(ofSize: fontSize)
      textColor = activeTextColor
      backgroundColor = today ? tintColor : selectedBackgroundColor
    } else {
      let notTodayColor = date.isWeekend ? weekendTextColor : inactiveTextColor
      font = UIFont.systemFont(ofSize: fontSize)
      textColor = today ? tintColor : notTodayColor
      backgroundColor = inactiveBackgroundColor
    }
  }

  func animate(){
    UIView.transition(with: self, duration: 0.4,
      options: .transitionCrossDissolve,
      animations: { _ in
        self.updateState()
      }, completion: nil)
  }

  override func layoutSubviews() {
    layer.cornerRadius = bounds.height / 2
  }
  override func tintColorDidChange() {
    updateState()
  }
}
