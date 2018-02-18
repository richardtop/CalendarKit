import UIKit
import DateToolsSwift

open class DayViewController: UIViewController, EventDataSource, DayViewDelegate {

  public lazy var dayView: DayView = DayView()

  open override func loadView() {
    view = dayView
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    edgesForExtendedLayout = []
    view.tintColor = UIColor.red
    dayView.dataSource = self
    dayView.delegate = self
    dayView.reloadData()
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    dayView.scrollToFirstEventIfNeeded()
  }

  open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)
    dayView.transitionToHorizontalSizeClass(newCollection.horizontalSizeClass)
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

  open func dayViewDidSelectEventView(_ eventView: EventView) {
  }

  open func dayViewDidLongPressEventView(_ eventView: EventView) {
  }

  open func dayViewDidLongPressTimelineAtHour(_ hour: Int) {
  }

  open func dayView(dayView: DayView, willMoveTo date: Date) {
  }

  open func dayView(dayView: DayView, didMoveTo date: Date) {
  }
}
