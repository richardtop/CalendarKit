
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
    backgroundColor = UIColor.lightGray
    clipsToBounds = true
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
//    let scrollViewWidth: CGFloat = bounds.width - allDayLabelWidth
    let allDayEventHeight: CGFloat = 24.0
    
    // create vertical stack view
    let verticalStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    verticalStackView.distribution = .fillEqually
    verticalStackView.axis = .vertical
    verticalStackView.spacing = 1.0
    var horizontalStackView: UIStackView! = nil
    
    for index in 0...nEventDescriptors - 1 {
      let eventDescriptor = dataSource.allDayView(self, eventDescriptorFor: index)
      
      // create event TODO: reuse event views
      let eventView = EventView(frame: CGRect.zero)
      eventView.updateWithDescriptor(event: eventDescriptor)
      eventView.heightAnchor.constraint(equalToConstant: allDayEventHeight).isActive = true
      
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
    
//    let nHorizontalStackViews: Int = nEventDescriptors / 2
    
    // create scroll view, vert. stack view inside, pin vert. stack view, update content view by the number of horz. stack views
    let scrollview = UIScrollView(frame: CGRect.zero)
    scrollview.isScrollEnabled = true
    scrollview.alwaysBounceVertical = true
    scrollview.clipsToBounds = false
    scrollview.addSubview(verticalStackView)
    
    verticalStackView.translatesAutoresizingMaskIntoConstraints = false
    verticalStackView.trailingAnchor.constraint(equalTo: scrollview.trailingAnchor, constant: 0).isActive = true
    verticalStackView.topAnchor.constraint(equalTo: scrollview.topAnchor, constant: 0).isActive = true
    verticalStackView.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: 0).isActive = true
    verticalStackView.bottomAnchor.constraint(equalTo: scrollview.bottomAnchor, constant: 0).isActive = true
    verticalStackView.widthAnchor.constraint(equalTo: scrollview.widthAnchor, multiplier: 1).isActive = true
    let verticalStackViewHeightConstraint = verticalStackView.heightAnchor.constraint(equalTo: scrollview.heightAnchor, multiplier: 1)
    verticalStackViewHeightConstraint.priority = UILayoutPriority(rawValue: 999)
    verticalStackViewHeightConstraint.isActive = true
    
    addSubview(scrollview)
    
    scrollview.translatesAutoresizingMaskIntoConstraints = false
    scrollview.leftAnchor.constraint(equalTo: leftAnchor, constant: allDayLabelWidth).isActive = true
    scrollview.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
    scrollview.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    bottomAnchor.constraint(equalTo: scrollview.bottomAnchor, constant: 2).isActive = true
    
    let maxAllDayViewHeight = allDayEventHeight * 2 + allDayEventHeight * 0.5
    heightAnchor.constraint(lessThanOrEqualToConstant: maxAllDayViewHeight).isActive = true
  }
  
  // MARK: - IBACTIONS/IBOUTLETS
  
  // MARK: - LIFE CYCLE

}
