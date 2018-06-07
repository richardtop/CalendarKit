
import UIKit

public class AllDayView: UIView {
  
  internal weak var eventViewDelegate: EventViewDelegate?
  
  var style = AllDayStyle()
  
  let allDayLabelWidth: CGFloat = 53.0
  let allDayEventHeight: CGFloat = 24.0
  
  public var events: [EventDescriptor] = [] {
    didSet {
      self.reloadData()
    }
  }
  
  private lazy var textLabel: UILabel = {
    let label = UILabel(frame: CGRect(x: 8.0, y: 4.0, width: allDayLabelWidth, height: 24.0))
    label.text = "all-day"
    label.autoresizingMask = [.flexibleWidth]
    
    return label
  }()

  /**
   vertical scroll view that contains the all day events in rows with only 2
   columns at most
   */
  private(set) lazy var scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.translatesAutoresizingMaskIntoConstraints = false
    addSubview(sv)
    
    sv.isScrollEnabled = true
    sv.alwaysBounceVertical = true
    sv.clipsToBounds = false
    
    let svLeftConstraint = sv.leadingAnchor.constraint(equalTo: leadingAnchor, constant: allDayLabelWidth)
    
    /**
     Why is this constraint 999?
     
     Since AllDayView and its constraints are set to its superview and layed out
     before the superview's width is updated from 0 to it's computed width (screen width),
     this constraint produces conflicts. Thus, allowing this constraint to be broken
     prevents conflicts trying to layout this view with the superview.width = 0
     
     More on this:
     this scope of code is first invoked here:
     
     ````
     @@ public class TimelineView: UIView, ReusableView, AllDayViewDataSource {
     ...
     public var layoutAttributes: [EventLayoutAttributes] {
        ...
        allDayView.reloadData()
        ...
     }
     ````
     
     the superview.width is calcuated here:
     
     ````
     @@ public class TimelineContainer: UIScrollView, ReusableView {
     ...
     override public func layoutSubviews() {
        timeline.frame = CGRect(x: 0, y: 0, width: width, height: timeline.fullHeight)
        ...
     }
     ````
     */
    svLeftConstraint.priority = UILayoutPriority(rawValue: 999)
    
    svLeftConstraint.isActive = true
    sv.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
    sv.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    bottomAnchor.constraint(equalTo: sv.bottomAnchor, constant: 2).isActive = true
    
    let maxAllDayViewHeight = allDayEventHeight * 2 + allDayEventHeight * 0.5
    heightAnchor.constraint(lessThanOrEqualToConstant: maxAllDayViewHeight).isActive = true
    
    return sv
  }()
  
  // MARK: - RETURN VALUES
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configure()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    configure()
  }
  
  // MARK: - METHODS
  
  /**
   scrolls the contentOffset of the scroll view containg the event views to the
   bottom
   */
  public func scrollToBottom(animated: Bool = false) {
    let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
    scrollView.setContentOffset(bottomOffset, animated: animated)
  }
  
  public func updateStyle(_ newStyle: AllDayStyle) {
    style = newStyle.copy() as! AllDayStyle
    
    backgroundColor = style.backgroundColor
    textLabel.font = style.allDayFont
    textLabel.textColor = style.allDayColor
  }
  
  private func configure() {
    clipsToBounds = true
    
    //add All-Day UILabel
    addSubview(textLabel)
    
    updateStyle(self.style)
  }
  
  public func reloadData() {
    defer {
      layoutIfNeeded()
    }
    
    // clear event views from scroll view
    scrollView.subviews.forEach { $0.removeFromSuperview() }
    
    if self.events.count == 0 { return }
    
    // create vertical stack view
    let verticalStackView = UIStackView(
      distribution: .fillEqually,
      spacing: 1.0
    )
    var horizontalStackView: UIStackView! = nil
    
    for (index, anEventDescriptor) in self.events.enumerated() {
      
      // create event
      let eventView = EventView(frame: CGRect.zero)
      eventView.updateWithDescriptor(event: anEventDescriptor)
      eventView.delegate = self.eventViewDelegate
      eventView.heightAnchor.constraint(equalToConstant: allDayEventHeight).isActive = true
      
      // create horz stack view if index % 2 == 0
      if index % 2 == 0 {
        horizontalStackView = UIStackView(
          axis: .horizontal,
          distribution: .fillEqually,
          spacing: 1.0
        )
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
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
  
  // MARK: - LIFE CYCLE
  
}

