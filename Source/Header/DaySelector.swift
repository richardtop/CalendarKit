import UIKit
import Neon
import DateTools

protocol DaySelectorDelegate: class {
  func dateSelectorDidSelectDate(date: NSDate)
}

class DaySelector: UIView {

  weak var delegate: DaySelectorDelegate?

  //TODO: change to support Work-week only (5 days instead of 7)
  var daysInWeek = 7
  var startDate = NSDate()
  var dateLabelWidth: CGFloat = 35

  var dateLabels = [DateLabel]()

  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeViews()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeViews()
  }

  func initializeViews() {
    for _ in 1...daysInWeek {
      let label = DateLabel()
      dateLabels.append(label)
      addSubview(label)

      let recognizer = UITapGestureRecognizer(target: self,
        action: "dateLabelDidTap:")
      label.addGestureRecognizer(recognizer)
    }
    configure()
  }

  func configure() {
    for (increment, label) in dateLabels.enumerate() {
      label.date = startDate.dateByAddingDays(increment)
    }
  }

  override func layoutSubviews() {
    let dateLabelsCount = CGFloat(dateLabels.count)
    var per = frame.size.width - dateLabelWidth * dateLabelsCount
    per /= dateLabelsCount
    let minX = per / 2

    //TODO refactor swifty math by applying extension ?
    for (i, label) in dateLabels.enumerate() {
      let frame = CGRect(x: minX + (dateLabelWidth + per) * CGFloat(i), y: 0,
        width: dateLabelWidth, height: dateLabelWidth)
      label.frame = frame
    }
  }

  func dateLabelDidTap(sender: UITapGestureRecognizer) {
    if let label = sender.view as? DateLabel {
      print(label.date)
      delegate?.dateSelectorDidSelectDate(label.date)
      dateLabels.filter {$0.selected == true}
        .first?.selected = false
      label.selected = true
    }
  }
}
