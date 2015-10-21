import UIKit
import Neon

class DayView: UIView {

  var headerHeight: CGFloat = 88

  let dayHeaderView = DayHeaderView()
  let timelinePager = PagingScrollView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    configureTimelinePager()
    addSubview(dayHeaderView)
  }

  func configureTimelinePager() {
    for _ in 0...2 {
      let timeline = TimelineView(frame: bounds)
      timeline.frame.size.height = timeline.fullHeight

      let verticalScrollView = UIScrollView(frame: bounds)
      verticalScrollView.addSubview(timeline)
      verticalScrollView.contentSize = timeline.frame.size

      timelinePager.addSubview(verticalScrollView)
      timelinePager.reusableViews.append(verticalScrollView)
    }

    let contentWidth = CGFloat(timelinePager.reusableViews.count) * bounds.width
    let contentHeight = timelinePager.reusableViews.first!.bounds.height
    let size = CGSize(width: contentWidth, height: contentHeight)
    timelinePager.contentSize = size

    addSubview(timelinePager)
  }

  override func layoutSubviews() {
    dayHeaderView.anchorAndFillEdge(.Top, xPad: 0, yPad: 20, otherSize: headerHeight)
    dayHeaderView.clipsToBounds = true

    timelinePager.alignAndFill(align: .UnderCentered, relativeTo: dayHeaderView, padding: 0)
  }
}
