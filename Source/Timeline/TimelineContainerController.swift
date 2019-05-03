import UIKit

public class TimelineContainerController: UIViewController {
  /// Content Offset to be set once the view size has been calculated
  var pendingContentOffset: CGPoint?

  lazy var timeline = TimelineView()
  lazy var container: TimelineContainer = {
    let view = TimelineContainer(timeline)
    view.addSubview(timeline)
    return view
  }()

  public override func loadView() {
    view = container
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    container.contentSize = timeline.frame.size
    if let newOffset = pendingContentOffset {
      // Apply new offset only once the size has been determined
      if view.bounds != .zero {
        container.setContentOffset(newOffset, animated: false)
        container.setNeedsLayout()
        pendingContentOffset = nil
      }
    }
  }
}
