import UIKit
import Neon

public class DayViewController: UIViewController {

  lazy var dayView: DayView = DayView()

  override public func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(dayView)
  }

  public override func viewDidLayoutSubviews() {
    dayView.fillSuperview()
  }
}
