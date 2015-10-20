import UIKit

public class DayViewController: UIViewController {

//  lazy var dayView: DayView = DayView()

  override public func viewDidLoad() {
    super.viewDidLoad()

    let dayView = DayView(frame: view.bounds)

    dayView.frame = view.bounds
    view.addSubview(dayView)
  }
}
