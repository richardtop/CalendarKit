//
//  File.swift
//  
//
//  Created by Kenneth Hom on 5/24/21.
//

import Foundation
import UIKit

public class CheckmarkButtonView: UIButton {
    
    public let gradient: CAGradientLayer = CAGradientLayer()
    
    public var isChecked: Bool = false {
        didSet {
            if isChecked {
                removeGlassEffect()
            } else {
                addGlassEffect()
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        gradient.colors = [UIColor.white.withAlphaComponent(0.6).cgColor, UIColor.white.withAlphaComponent(0.3).cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
    }
    
    private func addGlassEffect() {
        if !(layer.sublayers?.contains(gradient) ?? false) {
            self.layer.insertSublayer(gradient, at: 0)
        }
        
        let image = UIImage(named: "checkmarkDisabled")
        self.setImage(image, for: .normal)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        self.backgroundColor = .clear
    }
    
    private func removeGlassEffect() {
        gradient.removeFromSuperlayer()
        self.layer.borderWidth = 0
        let image = UIImage(named: "checkmarkComplete")
        self.setImage(image, for: .normal)
        self.backgroundColor = UIColor(hex: 0x1CBF02)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width/2
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
