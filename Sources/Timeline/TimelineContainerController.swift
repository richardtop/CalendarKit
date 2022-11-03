import UIKit

public final class TimelineContainerController: UIViewController {
  /// Content Offset to be set once the view size has been calculated
  public var pendingContentOffset: CGPoint?
  
  public private(set) lazy var timeline = TimelineView()
  public private(set) lazy var container: TimelineContainer = {
    let view = TimelineContainer(timeline)
    view.parent = self
    view.addSubview(timeline)
    return view
  }()
  
  public override func loadView() {
    view = container
  }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let parent = self.parent as? CKPageViewController else { return }
        
        if let offset = parent.commonOffset {
            container.setContentOffset(offset, animated: false)
        } else if let pendingOffset = self.pendingContentOffset {
            container.setContentOffset(pendingOffset, animated: false)
        }
    }
    
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    container.contentSize = timeline.frame.size
      if let parent = self.parent as? CKPageViewController {
          if parent.isFirstLaunch {
              container.scroollToCurrentTime(animated: true)
              parent.isFirstLaunch = false
          }
      }
      
      if let newOffset = self.pendingContentOffset {
      // Apply new offset only once the size has been determined
      if view.bounds != .zero {
        container.setContentOffset(newOffset, animated: false)
        container.setNeedsLayout()
        pendingContentOffset = nil
      }
    }
  }
}
