import UIKit
import DateTools

open class DayViewController: UIViewController, DayViewDelegate {

  lazy var dayView: DayView = DayView()

  override open func viewDidLoad() {
    super.viewDidLoad()
    self.edgesForExtendedLayout = UIRectEdge()
    view.addSubview(dayView)
    view.tintColor = UIColor.red

    dayView.dataSource = self
  }

  open override func viewDidLayoutSubviews() {
    dayView.fillSuperview()
  }
}

extension DayViewController: DayViewDataSource {
  func eventViewsForDate(_ date: Date) -> [EventView] {

    return generateMockEventsForDate(date)
  }


  func generateMockEventsForDate(_ date: Date) -> [EventView] {
    var date = date
    var events = [EventView]()
    let step = 2

    date = date.add(TimeChunk(seconds: 0, minutes: 24, hours: 0, days: 0, weeks: 0, months: 0, years: 0))

    for i in 0...10  {
      let event = EventView()

      let duration = Int(arc4random_uniform(60) + 30)
        let datePeriod = TimePeriod(beginning: date, duration: Double(duration))

      event.datePeriod = datePeriod

      var eventInfo = [String]()
      eventInfo.append("Text \(i)")
//      eventInfo.append(datePeriod.startDate.formattedDate(with: .full))

      event.data = eventInfo

      date = date.add(TimeChunk(seconds: 0, minutes: 24, hours: 0, days: 0, weeks: 0, months: 0, years: 0))
      events.append(event)
    }

    return events
  }

  // MARK: DayViewDelegate

  func dayViewDidSelectEventView(_ eventview: EventView) {

  }

  func dayViewDidLongPressEventView(_ eventView: EventView) {

  }
}
