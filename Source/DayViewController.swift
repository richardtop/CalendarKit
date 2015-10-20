import UIKit

public class DayViewController: UIViewController {

  lazy var dayView: DayView = DayView()

  override public func viewDidLoad() {
    super.viewDidLoad()

    dayView.frame = view.bounds
    view.addSubview(dayView)
  }
}
