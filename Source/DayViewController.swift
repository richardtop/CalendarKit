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
    dayView.reloadData()
  }

  open override func viewDidLayoutSubviews() {
    dayView.fillSuperview()
  }
}

extension DayViewController: DayViewDataSource {
  func eventViewsForDate(_ date: Date) -> [EventView] {
    return [EventView]()
  }

  // MARK: DayViewDelegate

  func dayViewDidSelectEventView(_ eventview: EventView) {

  }

  func dayViewDidLongPressEventView(_ eventView: EventView) {
    
  }
}
