
import UIKit

public protocol AllDayViewDataSource {
  func numberOfAllDayEvents(in allDayView: AllDayView) -> Int
  func allDayView(_ allDayView: AllDayView, eventDescriptorFor index: Int) -> EventDescriptor
}

public class AllDayView: UIView {
  
  public var dataSource: AllDayViewDataSource?

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configure()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    configure()
  }
  
  // MARK: - RETURN VALUES
  
  // MARK: - METHODS
  
  private func configure() {
    backgroundColor = UIColor.gray
    reloadData()
  }
  
  public func reloadData() {
    guard let dataSource = self.dataSource else {
      return
    }
    
    // clear subviews TODO: clear out only contents of scroll view
    subviews.forEach { $0.removeFromSuperview() }
    
    let nEventDescriptors = dataSource.numberOfAllDayEvents(in: self)
    if nEventDescriptors == 0 || nEventDescriptors < 0 { return }
    
    //TODO: add All-Day UILabel
    
    //TODO: remove local vars by using properties
    let allDayLabelWidth: CGFloat = 53.0
    let scrollViewWidth: CGFloat = bounds.width - allDayLabelWidth
    let eventViewHeight: CGFloat = 32.0
    
    // create vertical stack view
    let verticalStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    verticalStackView.distribution = .fillEqually
    verticalStackView.axis = .vertical
    verticalStackView.spacing = 1.0
    var horizontalStackView: UIStackView! = nil
    
    for index in 0...nEventDescriptors - 1 {
      let eventDescriptor = dataSource.allDayView(self, eventDescriptorFor: index)
      
      // create event TODO: reuse event views
      let eventRect = CGRect(x: 0, y: 0, width: 10, height: 10)
      let eventView = EventView(frame: eventRect)
      eventView.updateWithDescriptor(event: eventDescriptor)
      
      // create horz stack view if index % 2 == 0
      if index % 2 == 0 {
        horizontalStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.spacing = 1.0
        verticalStackView.addArrangedSubview(horizontalStackView)
      }
      
      // add eventView to horz. stack view
      horizontalStackView.addArrangedSubview(eventView)
    }
    
    let nHorizontalStackViews: Int = nEventDescriptors / 2
    
    // create scroll view, vert. stack view inside, pin vert. stack view, update content view by the number of horz. stack views
    let scrollViewHeight = min(eventViewHeight * 2 + eventViewHeight * 0.5, CGFloat(nHorizontalStackViews) * eventViewHeight)
    let scrollview = UIScrollView(frame: CGRect(x: allDayLabelWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight))
    scrollview.isScrollEnabled = true
    scrollview.alwaysBounceVertical = true
    scrollview.addSubview(verticalStackView)
    verticalStackView.translatesAutoresizingMaskIntoConstraints = false
    verticalStackView.trailingAnchor.constraint(equalTo: scrollview.trailingAnchor, constant: 0).isActive = true
    verticalStackView.topAnchor.constraint(equalTo: scrollview.topAnchor, constant: 0).isActive = true
    verticalStackView.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: 0).isActive = true
    verticalStackView.bottomAnchor.constraint(equalTo: scrollview.bottomAnchor, constant: 0).isActive = true
    verticalStackView.widthAnchor.constraint(equalTo: scrollview.widthAnchor, multiplier: 1).isActive = true
    verticalStackView.heightAnchor.constraint(equalToConstant: CGFloat(nHorizontalStackViews) * (eventViewHeight + 1))
    scrollview.heightAnchor.constraint(equalTo: verticalStackView.heightAnchor, multiplier: 1).isActive = true
//    verticalStackView.heightAnchor.constraint(equalTo: scrollview.heightAnchor, multiplier: 1).isActive = true
//    scrollview.contentSize = CGSize(width: scrollViewWidth, height: )
    
    addSubview(scrollview)
    scrollview.translatesAutoresizingMaskIntoConstraints = false
    scrollview.leftAnchor.constraint(equalTo: leftAnchor, constant: allDayLabelWidth).isActive = true
    scrollview.topAnchor.constraint(equalTo: topAnchor, constant: 0.0).isActive = true
    scrollview.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    scrollview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
  }
  
  // MARK: - IBACTIONS/IBOUTLETS
  
  // MARK: - LIFE CYCLE

}
