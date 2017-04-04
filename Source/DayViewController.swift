import UIKit
import DateToolsSwift

open class DayViewController: UIViewController, DayViewDataSource, DayViewDelegate {

  public lazy var dayView: DayView = DayView()

  override open func viewDidLoad() {
    super.viewDidLoad()
    self.edgesForExtendedLayout = UIRectEdge()
    view.addSubview(dayView)
    view.tintColor = UIColor.red

    dayView.dataSource = self
    dayView.delegate = self
    dayView.reloadData()
  }

  open override func viewDidLayoutSubviews() {
    dayView.fillSuperview()
  }

  open func reloadData() {
    dayView.reloadData()
  }

  open func updateStyle(_ newStyle: CalendarStyle) {
    dayView.updateStyle(newStyle)
  }

  open func eventsForDate(_ date: Date) -> [EventDescriptor] {
    return [Event]()
  }

  // MARK: DayViewDelegate

  open func dayViewDidSelectEventView(_ eventview: EventView) {

  }

  open func dayViewDidLongPressEventView(_ eventView: EventView) {

  }

  open func dayViewDidLongPressTimelineAtHour(_ hour: Int) {

  }

  open func dayView(dayView: DayView, willMoveTo date: Date) {
    print("DayView = \(dayView) will move to: \(date)")
  }

  open func dayView(dayView: DayView, didMoveTo date: Date) {
    print("DayView = \(dayView) did move to: \(date)")
  }
}
