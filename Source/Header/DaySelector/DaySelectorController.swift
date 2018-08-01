//
//  DaySelectorController.swift
//  CalendarKit
//
//  Created by Richard Topchii on 01/08/2018.
//

import UIKit

class DaySelectorController: UIViewController {
  lazy var daySelector = DaySelector()
  
  var delegate: DaySelectorDelegate? {
    get {
      return daySelector.delegate
    }
    set {
      daySelector.delegate = newValue
    }
  }
  
  var startDate: Date {
    get {
      return daySelector.startDate!
    }
    set {
      daySelector.startDate = newValue
    }
  }
  
  var selectedIndex: Int {
    get {
      return daySelector.selectedIndex
    }
    set {
      daySelector.selectedIndex = newValue
    }
  }
  
  var selectedDate: Date? {
    get {
      return daySelector.selectedDate
    }
    set {
      daySelector.selectedDate = newValue
    }
  }
  
  override func loadView() {
    view = daySelector
  }
}
