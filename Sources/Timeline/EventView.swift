import UIKit

open class EventView: UIView {
    public var descriptor: EventDescriptor?
    public var color = SystemColors.label
    
    public var contentHeight: Double {
        textView.frame.height
    }
    
    public private(set) lazy var topRightLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .right
            return label
        }()
    
    public private(set) lazy var textView: UITextView = {
        let view = UITextView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.clipsToBounds = true
        // Set custom edge insets to reduce excessive padding around the text content
        view.textContainerInset = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        return view
    }()
    
    /// Resize Handle views showing up when editing the event.
    /// The top handle has a tag of `0` and the bottom has a tag of `1`
    public private(set) lazy var eventResizeHandles = [EventResizeHandleView(), EventResizeHandleView()]
    
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
        addSubview(textView)
        addSubview(topRightLabel)
        layer.cornerRadius = 6
        layer.masksToBounds = true
        for (idx, handle) in eventResizeHandles.enumerated() {
            handle.tag = idx
            addSubview(handle)
        }
    }
    
    public func updateWithDescriptor(event: EventDescriptor) {
        if let attributedText = event.attributedText {
            textView.attributedText = attributedText
            textView.setNeedsLayout()
        } else {
            textView.text = event.text
            textView.textColor = event.textColor
            textView.font = event.font
        }
        if let lineBreakMode = event.lineBreakMode {
            textView.textContainer.lineBreakMode = lineBreakMode
        }
        
        if let rightLabelText = event.topRightLabel {
            topRightLabel.attributedText = rightLabelText
        }
        
        descriptor = event
        backgroundColor = .clear
        layer.backgroundColor = event.backgroundColor.cgColor
        layer.cornerRadius = 5
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
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.interpolationQuality = .none
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(8.0)
        context.setLineCap(.round)
        context.translateBy(x: 0, y: 0.5)
        let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
        let x: Double = leftToRight ? 0 : frame.width - 1.0  // 1 is the line width
        let y: Double = 0
        let hOffset: Double = 0
        let vOffset: Double = 0
        context.beginPath()
        context.move(to: CGPoint(x: x + 2 * hOffset, y: y + vOffset))
        context.addLine(to: CGPoint(x: x + 2 * hOffset, y: (bounds).height - vOffset))
        context.strokePath()
        context.restoreGState()
    }
    
    private var drawsShadow = false
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        showTrailingLabelIfFits()
        let rightSpacing = {
            if topRightLabel.isHidden {
                return 8.0
            } else {
                return topRightLabel.frame.width + 8.0
            }
        }()
        
        textView.frame = {
            if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft {
                return CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width - rightSpacing, height: bounds.height)
            } else {
                return CGRect(x: bounds.minX + 8, y: bounds.minY, width: bounds.width - rightSpacing, height: bounds.height)
            }
        }()
        
        if frame.minY < 0 {
            var textFrame = textView.frame;
            textFrame.origin.y = frame.minY * -1;
            textFrame.size.height += frame.minY;
            textView.frame = textFrame;
        }
        let first = eventResizeHandles.first
        let last = eventResizeHandles.last
        let radius: Double = 40
        let yPad: Double =  -radius / 2
        let width = bounds.width
        let height = bounds.height
        let size = CGSize(width: radius, height: radius)
        first?.frame = CGRect(origin: CGPoint(x: width - radius - layoutMargins.right, y: yPad),
                              size: size)
        last?.frame = CGRect(origin: CGPoint(x: layoutMargins.left, y: height - yPad - radius),
                             size: size)
        
        if drawsShadow {
            applySketchShadow(alpha: 0.13,
                              blur: 10)
        }
    }
    
    private func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: Double = 0,
        y: Double = 2,
        blur: Double = 4,
        spread: Double = 0)
    {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = alpha
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowRadius = blur / 2.0
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    
    private func showTrailingLabelIfFits() {
        let rightLabelPadding: CGFloat = 10
        let rightLabelWidth: CGFloat = 90
        let rightLabelHeight: CGFloat = 20
        let rightLabelYPositionOffset: CGFloat = 5
        let eventWidth = superview?.bounds.width ?? 410
        let smallerEventWidth = eventWidth/2
        
        if bounds.width >= smallerEventWidth {
            topRightLabel.isHidden = false
            topRightLabel.frame = CGRect(x: bounds.maxX - rightLabelWidth - rightLabelPadding,
                                         y: bounds.minY + rightLabelYPositionOffset,
                                         width: rightLabelWidth,
                                         height: rightLabelHeight)
        } else {
            topRightLabel.isHidden = true
        }
    }
    
    //MARK: On clcik effect on event.
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dimEvent()
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        resetDim()
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        resetDim()
    }

    private func dimEvent() {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.7
        }
    }

    private func resetDim() {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1.0
        }
    }
}
