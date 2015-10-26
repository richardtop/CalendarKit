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

    for i in 0...10  {
      let event = EventView()

      let duration = Int(arc4random_uniform(60) + 30)
      let datePeriod = DTTimePeriod(size: .Minute, amount: duration, startingAt: date)

      event.datePeriod = datePeriod
      event.titleLabel.text = "Text \(i)"

      date = date.dateByAddingMinutes(Int(arc4random_uniform(180)))
      events.append(event)
    }

    return events
  }
}