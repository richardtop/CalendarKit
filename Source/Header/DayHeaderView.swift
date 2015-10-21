import UIKit
import Neon

protocol DayHeaderViewDelegate: class {

}

class DayHeaderView: UIView {

  var daySymbolsViewHeight: CGFloat = 17
  var pagingScrollViewHeight: CGFloat = 50
  var swipeLabelViewHeight: CGFloat = 20

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

    daySymbolsView.backgroundColor = UIColor.blueColor()
    pagingScrollView.backgroundColor = UIColor.grayColor()
    swipeLabelView.backgroundColor = UIColor.greenColor()
    swipeLabelView.date = NSDate()
    swipeLabelView.layoutSubviews()


    configurePages()
  }



  func configurePages() {
    var screenSize = bounds.size
    screenSize.height = 50.0

    for _ in 0...2 {
      let daySelector = DaySelector()
      pagingScrollView.reusableViews.append(daySelector)
      pagingScrollView.addSubview(daySelector)
      daySelector.delegate = self
    }

    screenSize.width = 375 * 3
    screenSize.height = 50.0
    pagingScrollView.contentSize = screenSize

  }


  override func layoutSubviews() {
    super.layoutSubviews()

    daySymbolsView.anchorAndFillEdge(.Top, xPad: 0, yPad: 0, otherSize: daySymbolsViewHeight)
    pagingScrollView.alignAndFillWidth(align: .UnderCentered, relativeTo: daySymbolsView, padding: 0, height: pagingScrollViewHeight)
    swipeLabelView.anchorAndFillEdge(.Bottom, xPad: 0, yPad: 0, otherSize: swipeLabelViewHeight)
    pagingScrollView.recenterIfNecessary()
  }
}

extension DayHeaderView: DaySelectorDelegate {
  func dateSelectorDidSelectDate(date: NSDate) {
    swipeLabelView.date = date
  }
}
