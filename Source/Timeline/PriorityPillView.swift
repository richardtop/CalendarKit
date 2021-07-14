//
//  File.swift
//  
//
//  Created by Kenneth Hom on 4/1/21.
//

import Foundation
import UIKit

public class PillView: UIView {
    public var text: NSAttributedString? = NSAttributedString(string: "") {
        didSet {
            label.attributedText = text
            setNeedsLayout()
        }
    }
    public var color: UIColor? {
        didSet {
            if color != nil {
                colorLabel.color = color!
                stack.insertArrangedSubview(colorLabel, at: 1)
            } else {
                stack.removeArrangedSubview(colorLabel)
            }
            setNeedsLayout()
        }
    }
    
    public lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [UIView(), label, UIView()])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()
    
    let label = UILabel()
    let colorLabel = Circle()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stack)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        CGSize(width: 20 + colorLabel.intrinsicContentSize.width + label.intrinsicContentSize.width, height: label.intrinsicContentSize.height + 5)
    }
    
    override public func layoutSubviews() {
        stack.frame =  CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        layer.cornerRadius = bounds.height/2
    }
    
}

class Circle: UIView {
    
    var color: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 8, height: 8)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        var path = UIBezierPath()
        path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 8, height: 8))
        color.setFill()
        path.fill()
    }
}
