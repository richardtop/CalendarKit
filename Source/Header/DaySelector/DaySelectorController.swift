import UIKit

public final class DaySelectorController: UIViewController {
  public private(set) lazy var daySelector = DaySelector()
  
  public var delegate: DaySelectorDelegate? {
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
  
  public var startDate: Date {
    get {
      return daySelector.startDate!
    }
    set {
      daySelector.startDate = newValue
    }
  }
  
  public var selectedIndex: Int {
    get {
      return daySelector.selectedIndex
    }
    set {
      daySelector.selectedIndex = newValue
    }
  }
  
  public var selectedDate: Date? {
    get {
      return daySelector.selectedDate
    }
    set {
      daySelector.selectedDate = newValue
    }
  }
  
  override public func loadView() {
    view = daySelector
  }
  
  func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
    daySelector.transitionToHorizontalSizeClass(sizeClass)
  }
  
  public func updateStyle(_ newStyle: DaySelectorStyle) {
    daySelector.updateStyle(newStyle)
  }
}
