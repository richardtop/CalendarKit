//
//  ExampleCustomTimeLineController.swift
//  CalendarKitDemo
//
//  Created by Fidel Esteban Morales Cifuentes on 7/5/19.
//  Copyright © 2019 Hyper. All rights reserved.
//

import Foundation
import CalendarKit

class ExampleCustomTimeLineController: DayViewController {

  var customTimelineView: UIView? = nil {
    didSet {
      // Initialize dayView
      dayView = DayView(customView: customTimelineView)
    }
  }

  private let ourCustomLabel = UILabel()

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    setupLabel()
    dayView.stateDelegate = self
  }

  private func setupLabel() {
    guard let customTimelineView = dayView.customView else { return }
    ourCustomLabel.numberOfLines = 0
    ourCustomLabel.text = textFor(date: dayView.state?.selectedDate)
    ourCustomLabel.center = customTimelineView.center
    ourCustomLabel.frame = customTimelineView.frame
    customTimelineView.addSubview(ourCustomLabel)
  }

  private func textFor(date: Date?) -> String{
    var text = "This is a regular UIView. Do anything you want with it."
    if let selectedDate = date?.format(with: .full) {
      text = "\(text) For example display the selected date: \(selectedDate)"
    }
    return text
  }
}

// MARK: - DayViewStateUpdating
extension ExampleCustomTimeLineController: DayViewStateUpdating {
  func move(from oldDate: Date, to newDate: Date) {
    ourCustomLabel.text = textFor(date: newDate)
  }
}
