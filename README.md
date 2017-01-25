[![CI Status](http://img.shields.io/travis/richardtop/CalendarKit.svg?style=flat)](https://travis-ci.org/hyperoslo/CalendarKit)
[![Version](https://img.shields.io/cocoapods/v/CalendarKit.svg?style=flat)](http://cocoadocs.org/docsets/CalendarKit)
[![License](https://img.shields.io/cocoapods/l/CalendarKit.svg?style=flat)](http://cocoadocs.org/docsets/CalendarKit)
[![Platform](https://img.shields.io/cocoapods/p/CalendarKit.svg?style=flat)](http://cocoadocs.org/docsets/CalendarKit)

# CalendarKit
**CalendarKit** is a fully customizable calendar library written in Swift.
It was designed to look similar to iOS Calendar app out-of-the-box, but allow complete customization when needed.
To make modifications easy, CalendarKit is composed of multiple small modules. They can be used together, or on their own.

## Installation

**CalendarKit** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following lines to your Podfile:

```ruby
pod 'CalendarKit'
pod 'DateTools', :git => 'https://github.com/MatthewYork/DateTools.git', :branch => 'swift'
```
For now, it is required to specify DateTools `swift` branch, as it is still in beta. When swift version of DateTools is released, this line could be removed.

## Usage
### Subclass DayViewController and implement `DayViewDataSource` protocol to show events

```swift
    // Return an array of EventViews for particular date
  override func eventViewsForDate(_ date: Date) -> [EventView] {
    var events = // Get events (models) from the storage / API

    var views = [EventView]()

    for event in events {
        // Create new EventView
        let view = EventView()
        // Specify TimePeriod
        view.datePeriod = TimePeriod(beginning: event.beginning, end: event.start)
        // Add info: event title, subtitle, location to the array of Strings
        var info = [event.title, event.location]
        info.append("\(datePeriod.beginning!.format(with: "HH:mm")!) - \(datePeriod.end!.format(with: "HH:mm")!)")
        view.data = info
        views.append(view)
    }

    return views
  }
```

### If needed, implement DayViewDelegate to handle user input

```swift
  override func dayViewDidSelectEventView(_ eventview: EventView) {
    print("Event has been selected: \(eventview.data)")
  }
  
  override func dayViewDidLongPressEventView(_ eventView: EventView) {
    print("Event has been longPressed: \(eventView.data)")
  }
```

## Requirements

- iOS 9.0+
- Swift 3.0+

## Dependencies
- **[Neon](https://github.com/mamaral/Neon)**
is used for declarative layout
- **[DateTools](https://github.com/MatthewYork/DateTools)**
is used for date manipulation
- **[DynamicColor](https://github.com/yannickl/DynamicColor)**
is used to update the colors of Events

## Author

Richard Topchii

## License

**CalendarKit** is available under the MIT license. See the LICENSE file for more info.
