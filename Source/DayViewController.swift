import UIKit
import DateTools

public class DayViewController: UIViewController {

  lazy var dayView: DayView = DayView()

  override public func viewDidLoad() {
    super.viewDidLoad()
    self.edgesForExtendedLayout = UIRectEdge.None
    view.addSubview(dayView)
    view.tintColor = UIColor.redColor()

    dayView.dataSource = self
  }

  public override func viewDidLayoutSubviews() {
    dayView.fillSuperview()
  }
}

extension DayViewController: DayViewDataSource {
  func eventViewsForDate(date: NSDate) -> [EventView] {

    let datePeriod = DTTimePeriod(size: .Hour, startingAt: date)
    let eventView = EventView()
    eventView.datePeriod = datePeriod

    return [eventView]
  }
}