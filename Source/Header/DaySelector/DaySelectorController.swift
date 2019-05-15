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

  public var calendar: Calendar {
    get {
      return daySelector.calendar
    }
    set(newValue) {
      daySelector.calendar = newValue
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
  
  func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
    daySelector.transitionToHorizontalSizeClass(sizeClass)
  }
  
  func updateStyle(_ newStyle: DaySelectorStyle) {
    daySelector.updateStyle(newStyle)
  }
}
