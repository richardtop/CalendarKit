import UIKit

class DayHeaderView: UIView {

  var daySymbolsViewHeight: CGFloat = 17

  let daySymbolsView = DaySymbolsView()
  let pagingScrollView = PagingScrollView()
  let swipeLabelView = SwipeLabelView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    [daySymbolsView, pagingScrollView, swipeLabelView]
      .forEach { addSubview($0) }


  }

  override func layoutSubviews() {
    var rect = bounds
    rect.size.height = daySymbolsViewHeight

    daySymbolsView.frame = rect
  }
}
