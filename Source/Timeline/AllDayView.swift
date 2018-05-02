
import UIKit

public protocol AllDayViewDataSource {
  func numberOfAllDayEvents(in allDayView: AllDayView) -> Int
  func allDayView(_ allDayView: AllDayView, eventDescriptorFor index: Int) -> EventDescriptor
}

public class AllDayView: UIView {
  
  let allDayLabelWidth: CGFloat = 53.0
  let allDayEventHeight: CGFloat = 24.0
  
  public var dataSource: AllDayViewDataSource?
  
  private(set) lazy var scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.translatesAutoresizingMaskIntoConstraints = false
    addSubview(sv)
    
    sv.isScrollEnabled = true
    sv.alwaysBounceVertical = true
    sv.clipsToBounds = false
    
    sv.leadingAnchor.constraint(equalTo: leadingAnchor, constant: allDayLabelWidth).isActive = true
    sv.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
    sv.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    bottomAnchor.constraint(equalTo: sv.bottomAnchor, constant: 2).isActive = true
    
    let maxAllDayViewHeight = allDayEventHeight * 2 + allDayEventHeight * 0.5
    heightAnchor.constraint(lessThanOrEqualToConstant: maxAllDayViewHeight).isActive = true
    
    return sv
  }()

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
    scrollView.subviews.forEach { $0.removeFromSuperview() }
    
    let nEventDescriptors = dataSource.numberOfAllDayEvents(in: self)
    if nEventDescriptors == 0 || nEventDescriptors < 0 { return }
    
    //TODO: add All-Day UILabel
    
    // create vertical stack view
    let verticalStackView = UIStackView(frame: CGRect.zero)
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
        horizontalStackView = UIStackView(frame: CGRect.zero)
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.spacing = 1.0
        verticalStackView.addArrangedSubview(horizontalStackView)
      }
      
      // add eventView to horz. stack view
      horizontalStackView.addArrangedSubview(eventView)
    }
    
    // add vert. stack view inside, pin vert. stack view, update content view by the number of horz. stack views
    verticalStackView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(verticalStackView)
    
    verticalStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
    verticalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
    verticalStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
    verticalStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
    verticalStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1).isActive = true
    let verticalStackViewHeightConstraint = verticalStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1)
    verticalStackViewHeightConstraint.priority = UILayoutPriority(rawValue: 999)
    verticalStackViewHeightConstraint.isActive = true
  }
  
  public func scrollToBottom() {
    let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height);
    scrollView.setContentOffset(bottomOffset, animated: false)
  }
  
  // MARK: - IBACTIONS/IBOUTLETS
  
  // MARK: - LIFE CYCLE

}
