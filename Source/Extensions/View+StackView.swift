//
//  View+StackView.swift
//  CalendarKit
//
//  Created by Erick Sanchez on 5/10/18.
//

import UIKit

extension UIStackView {
	convenience init(axis: NSLayoutConstraint.Axis = .vertical,
				   distribution: UIStackView.Distribution = .fill,
				   alignment: UIStackView.Alignment = .fill,
                   spacing: CGFloat = 0,
                   subviews: [UIView] = []) {
    self.init(arrangedSubviews: subviews)
    self.axis = axis
    self.distribution = distribution
    self.alignment = alignment
    self.spacing = spacing
  }
}
