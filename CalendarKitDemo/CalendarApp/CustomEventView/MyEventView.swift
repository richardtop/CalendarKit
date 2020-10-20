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
    
    override public init(frame: CGRect) {
      super.init(frame: frame)
        let v = Bundle.main.loadNibNamed("MyEventView", owner: self, options: nil)?.first as! UIView
        self.addSubview(v)
    }

    required public init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      let v = Bundle.main.loadNibNamed("MyEventView", owner: self, options: nil)?.first as! UIView
      self.addSubview(v)
    }
    
    override func updateWithDescriptor(event: EventDescriptor) {
        super.updateWithDescriptor(event: event)
        self.color = .black
    }
}
