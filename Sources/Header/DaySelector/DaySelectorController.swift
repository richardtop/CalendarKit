import UIKit

public final class DaySelectorController: UIViewController {
    public private(set) lazy var daySelector = DaySelector()
    
    public var delegate: DaySelectorDelegate? {
        get {
            daySelector.delegate
        }
        set {
            daySelector.delegate = newValue
        }
    }
    
    public var calendar: Calendar {
        get {
            daySelector.calendar
        }
        set(newValue) {
            daySelector.calendar = newValue
        }
    }
    
    public var startDate: Date {
        get {
            daySelector.startDate!
        }
        set {
            daySelector.startDate = newValue
        }
    }
    
    public var selectedIndex: Int {
        get {
            daySelector.selectedIndex
        }
        set {
            daySelector.selectedIndex = newValue
        }
    }
    
    public var selectedDate: Date? {
        get {
            daySelector.selectedDate
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
