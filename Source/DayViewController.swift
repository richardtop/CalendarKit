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

    return generateMockEventsForDate(date)
  }


  func generateMockEventsForDate(var date: NSDate) -> [EventView] {
    var events = [EventView]()
    let step = 2

    date = date.dateByAddingMinutes(24)

    for _ in 0...5 {
      let event = EventView()
      let datePeriod = DTTimePeriod(size: .Hour, startingAt: date)
      event.datePeriod = datePeriod
      date = date.dateByAddingHours(step)
      events.append(event)
    }
    return events
  }
}