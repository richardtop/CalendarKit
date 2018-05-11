//
//  View+StackView.swift
//  CalendarKit
//
//  Created by Erick Sanchez on 5/10/18.
//

import UIKit

extension UIStackView {
  
  /**
   <#Lorem ipsum dolor sit amet.#>
   
   - parameter <#bar#>: <#Consectetur adipisicing elit.#>
   
   - returns: <#Sed do eiusmod tempor.#>
   */
  convenience init(axis: UILayoutConstraintAxis = .vertical,
                   distribution: UIStackViewDistribution = .fill,
                   alignment: UIStackViewAlignment = .fill,
                   spacing: CGFloat = 0,
                   subviews: [UIView] = []) {
    self.init(arrangedSubviews: subviews)
    self.axis = axis
    self.distribution = distribution
    self.alignment = alignment
    self.spacing = spacing
  }
}
