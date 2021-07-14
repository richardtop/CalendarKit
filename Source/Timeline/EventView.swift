import UIKit

public protocol EventViewDelegate: AnyObject {
    func didTapEdit(_ eventView: EventView)
    func didTapCheckMark(_ event: EventView)
}

open class EventView: UIView {
  public var descriptor: EventDescriptor?
  public var color = SystemColors.label
  public weak var delegate: EventViewDelegate?
  public var contentHeight: CGFloat {
    return textView.frame.height
  }

  public lazy var textView: UITextView = {
    let view = UITextView()
    view.isUserInteractionEnabled = false
    view.backgroundColor = .clear
    view.isScrollEnabled = false
    return view
  }()
    
    public lazy var titleTextView: UILabel = {
       let textView = UILabel()
        textView.numberOfLines = 1
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.lineBreakMode = .byWordWrapping
       return textView
    }()
    
    public lazy var subTitleTextView: UILabel = {
       let textView = UILabel()
        textView.numberOfLines = 1
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.lineBreakMode = .byTruncatingTail
       return textView
    }()
    
    public lazy var priorityPill: PillView = PillView(frame: .zero)
    public lazy var categoryTag: PillView = PillView(frame: .zero)
    
    private var priorityWidthConstaint = NSLayoutConstraint()
    private var priorityMinWidthConstaint = NSLayoutConstraint()
    private var priorityHeightConstraint = NSLayoutConstraint()
    
    private var categoryWidthConstraint = NSLayoutConstraint()
    private var categoryMinWidthConstraint = NSLayoutConstraint()
    private var categoryHeightConstraint = NSLayoutConstraint()
    
    private var stackLeading = NSLayoutConstraint()
    private var stackTop = NSLayoutConstraint()
    private var stackTrailing = NSLayoutConstraint()
    
    public lazy var pillStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [priorityPill, categoryTag])
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    public lazy var checkMark: CheckmarkButtonView  = {
        let button = CheckmarkButtonView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    public lazy var actionsButtons: UIButton = {
        let button = UIButton(frame: .zero)
        if let image = UIImage(named: "Option.png") {
            button.setImage(image, for: .normal)
        }
        button.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc public func didTapAction(button: UIButton, forEvent event: UIEvent) {
        delegate?.didTapEdit(self)
    }
    
    @objc public func didTapCheckmark(button: UIButton, forEvent event: UIEvent) {
        delegate?.didTapCheckMark(self)
    }
    
    lazy var lowerViewVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [subTitleTextView, pillStack])
        stack.axis = .vertical
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var lowerViewHStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [lowerViewVStack, checkMark])
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    public lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleTextView, actionsButtons])
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    public lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [hStack, lowerViewHStack])
        stack.axis = .vertical
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
  /// Resize Handle views showing up when editing the event.
  /// The top handle has a tag of `0` and the bottom has a tag of `1`
  public lazy var eventResizeHandles = [EventResizeHandleView(), EventResizeHandleView()]

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  private func configure() {
    clipsToBounds = false
    color = tintColor
    //addSubview(textView)
    checkMark.isChecked = true
    checkMark.setNeedsLayout()
    addSubview(vStack)
    priorityWidthConstaint = priorityPill.widthAnchor.constraint(equalToConstant: 0)
    priorityHeightConstraint = priorityPill.heightAnchor.constraint(equalToConstant: 0)
    priorityMinWidthConstaint = priorityPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
    
    
    categoryWidthConstraint = categoryTag.widthAnchor.constraint(equalToConstant: 0)
    categoryMinWidthConstraint = categoryTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
    categoryHeightConstraint = categoryTag.heightAnchor.constraint(equalToConstant: 0)

    stackTop = vStack.topAnchor.constraint(equalTo: topAnchor, constant: 0)
    stackLeading = vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
    stackTrailing = vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
    NSLayoutConstraint.activate([
        priorityWidthConstaint,
        priorityHeightConstraint,
        categoryWidthConstraint,
        categoryHeightConstraint,
        stackTrailing,
        stackTop,
        stackLeading,
        actionsButtons.heightAnchor.constraint(equalToConstant: 20),
        actionsButtons.widthAnchor.constraint(equalToConstant: 20),
        titleTextView.heightAnchor.constraint(equalToConstant: 20),
        titleTextView.widthAnchor.constraint(equalTo: vStack.widthAnchor, constant: -20),
        subTitleTextView.heightAnchor.constraint(equalToConstant: 13),
        subTitleTextView.widthAnchor.constraint(equalTo: vStack.widthAnchor),
        pillStack.heightAnchor.constraint(equalToConstant: 20),
        lowerViewHStack.trailingAnchor.constraint(lessThanOrEqualTo: vStack.trailingAnchor, constant: -25)
    ])
    
    for (idx, handle) in eventResizeHandles.enumerated() {
      handle.tag = idx
      addSubview(handle)
    }
  }

  public func updateWithDescriptor(event: EventDescriptor) {
    if let attributedText = event.attributedText {
     // textView.attributedText = attributedText
      titleTextView.attributedText = attributedText
    } else {
        titleTextView.attributedText = nil
    }
    
    if let subtitleText = event.subtitleText {
        subTitleTextView.attributedText = subtitleText
    } else {
        subTitleTextView.attributedText = nil
    }
    
    if event.taskId == nil {
        actionsButtons.isHidden = true
    } else {
        actionsButtons.isHidden = false
    }
    
    checkMark.isChecked = event.isChecked
    
    if let priority = event.priority, let priorityColor = event.priorityColor {
        priorityPill.text = priority
        priorityPill.color = priorityColor
        priorityHeightConstraint.constant = priorityPill.intrinsicContentSize.height
        priorityWidthConstaint.constant = priorityPill.intrinsicContentSize.width
        priorityMinWidthConstaint.constant = priorityPill.intrinsicContentSize.width/2
        priorityPill.isHidden = false
    } else {
        priorityPill.text = nil
        priorityPill.color = nil
        priorityPill.isHidden = true
        priorityHeightConstraint.constant = 0
        priorityWidthConstaint.constant = 0
        priorityMinWidthConstaint.constant = 0
    }
    
    if let categoryText = event.categoryText {
        categoryTag.text = categoryText
        categoryWidthConstraint.constant = categoryTag.intrinsicContentSize.width
        categoryHeightConstraint.constant = categoryTag.intrinsicContentSize.height
        categoryMinWidthConstraint.constant = categoryTag.intrinsicContentSize.width/2
        categoryTag.isHidden = false
    } else {
        categoryTag.text = nil
        categoryWidthConstraint.constant = 0
        categoryHeightConstraint.constant = 0
        categoryMinWidthConstraint.constant = 0
        categoryTag.isHidden = true
        
    }
    NSLayoutConstraint.activate([checkMark.heightAnchor.constraint(equalToConstant: 30),
                                 checkMark.widthAnchor.constraint(equalToConstant: 30)])

    /*else {
      textView.text = event.text
      textView.textColor = event.textColor
      textView.font = event.font
    } */
    if let lineBreakMode = event.lineBreakMode {
      textView.textContainer.lineBreakMode = lineBreakMode
    }
    descriptor = event
    backgroundColor = event.backgroundColor
    color = event.color
    eventResizeHandles.forEach{
      $0.borderColor = event.color
      $0.isHidden = event.editedEvent == nil
    }
    drawsShadow = event.editedEvent != nil
    setNeedsDisplay()
    setNeedsLayout()
  }
  
    
  public func animateCreation() {
    transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    func scaleAnimation() {
      transform = .identity
    }
    UIView.animate(withDuration: 0.2,
                   delay: 0,
                   usingSpringWithDamping: 0.2,
                   initialSpringVelocity: 10,
                   options: [],
                   animations: scaleAnimation,
                   completion: nil)
  }

  /**
   Custom implementation of the hitTest method is needed for the tap gesture recognizers
   located in the ResizeHandleView to work.
   Since the ResizeHandleView could be outside of the EventView's bounds, the touches to the ResizeHandleView
   are ignored.
   In the custom implementation the method is recursively invoked for all of the subviews,
   regardless of their position in relation to the Timeline's bounds.
   */
  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    for resizeHandle in eventResizeHandles {
      if let subSubView = resizeHandle.hitTest(convert(point, to: resizeHandle), with: event) {
        return subSubView
      }
    }
    return super.hitTest(point, with: event)
  }

  private var drawsShadow = false

  override open func layoutSubviews() {
    super.layoutSubviews()
   /* print("start")
    print("\(self.titleTextView.attributedText)")
    print("\(self.subTitleTextView.attributedText)")
    print("\(self.priorityPill.text)")
    print("\(self.categoryTag.text)")
    print(hStack.frame)
    print(hStack.isHidden)
    print(priorityPill.isHidden)
    print(stackHeight.constant)
    print(pillStack.frame)
    print("end")
    */
    if descriptor?.priority != nil, descriptor?.priorityColor != nil {
        priorityPill.isHidden = false
    } else {
        priorityPill.isHidden = true
    }
    
    if bounds.height < 60 {
        pillStack.isHidden = true
        checkMark.isHidden = true
        stackTop.constant = 2
        lowerViewVStack.spacing = 0
        stackLeading.constant = 6
        stackTrailing.constant = -6
    } else {
        pillStack.isHidden = false
        checkMark.isHidden = false
        stackTop.constant = 5
        lowerViewVStack.spacing = 5
        stackLeading.constant = 10
        stackTrailing.constant = -6
    }
    let first = eventResizeHandles.first
    let last = eventResizeHandles.last
    let radius: CGFloat = 40
    let yPad: CGFloat =  -radius / 2
    let width = bounds.width
    let height = bounds.height
    let size = CGSize(width: radius, height: radius)
    first?.frame = CGRect(origin: CGPoint(x: width - radius - layoutMargins.right, y: yPad),
                          size: size)
    last?.frame = CGRect(origin: CGPoint(x: layoutMargins.left, y: height - yPad - radius),
                         size: size)
    
    self.layer.cornerRadius = 10
    self.layer.masksToBounds = false
    self.layer.shadowColor = UIColor(hex: 0xA2BFF8).cgColor
    self.layer.shadowOpacity = 0.5
    self.layer.shadowOffset = CGSize(width: -1, height: 1)
    self.layer.shadowRadius = 1
    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
  }
}
