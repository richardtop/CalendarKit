//
//  MyEventView.swift
//  CalendarApp
//
//  Created by RareScrap on 19.10.2020.
//  Copyright © 2020 Richard Topchii. All rights reserved.
//

import Foundation
import CalendarKit

class MyEventView: EventView {
    
    override func configure() {
        super.configure()
        
        let v = Bundle.main.loadNibNamed("MyEventView", owner: self, options: nil)?.first as! UIView
        self.addSubview(v)
          
        v.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = v.topAnchor.constraint(equalTo: self.topAnchor)
        let verticalConstraint = v.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let widthConstraint = v.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        let heightConstraint = v.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        self.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])

    }
}
