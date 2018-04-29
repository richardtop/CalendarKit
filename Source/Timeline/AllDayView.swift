//
//  AllDayView.swift
//  workspace
//
//  Created by Erick Sanchez on 4/28/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

public protocol AllDayViewDataSource {
  func numberOfAllDayEvents(in allDayView: AllDayView) -> Int
  func allDayView(_ allDayView: AllDayView, eventDescriptorFor index: Int) -> EventDescriptor
}

public class AllDayView: UIView {
  
  public var dataSource: AllDayViewDataSource?

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
    
    reloadData()
  }
  
  public func reloadData() {
    guard let dataSource = self.dataSource else {
      return
    }
    
    let nEventDescriptors = dataSource.numberOfAllDayEvents(in: self)
    if nEventDescriptors == 0 || nEventDescriptors < 0 { return }
    
    // create vertical stack view
    
    for index in 0...nEventDescriptors {
      let eventDescriptor = dataSource.allDayView(self, eventDescriptorFor: index)
      
      // create event TODO: reuse event views
      
      // create horz stack view if index % 2 == 0
      
      // add eventView to horz. stack view
    }
    
    // create scroll view, vert. stack view inside, update content view
    
    // addSubview(scrollview)
  }
  
  // MARK: - IBACTIONS/IBOUTLETS
  
  // MARK: - LIFE CYCLE

}
