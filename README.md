![CalendarKit](https://cloud.githubusercontent.com/assets/8013017/22312394/aaf83e76-e368-11e6-8473-b3bcb4811803.png)
[![CI Status](http://img.shields.io/travis/richardtop/CalendarKit.svg?style=flat)](https://travis-ci.org/richardtop/CalendarKit)
[![Version](https://img.shields.io/cocoapods/v/CalendarKit.svg?style=flat)](http://cocoadocs.org/docsets/CalendarKit)
[![License](https://img.shields.io/cocoapods/l/CalendarKit.svg?style=flat)](http://cocoadocs.org/docsets/CalendarKit)
[![Platform](https://img.shields.io/cocoapods/p/CalendarKit.svg?style=flat)](http://cocoadocs.org/docsets/CalendarKit)

# CalendarKit
**CalendarKit** is a fully customizable calendar library written in Swift. It was designed to look similar to iOS Calendar app out-of-the-box, but allow complete customization when needed. To make modifications easy, CalendarKit is composed of multiple small modules. They can be used together, or on their own.

## Try it
You can try CalendarKit using CocoaPods. Just enter this line in Terminal:
```ruby
pod try CalendarKit
```
Or watch it live in [this video](https://www.youtube.com/watch?v=jWM6EfGSCWc)


## Installation

**CalendarKit** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CalendarKit'
```

## Usage
Subclass DayViewController and implement `DayViewDataSource` protocol to show events

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
There is  no need to do layout, CalendarKit will take care of it.

If needed, implement DayViewDelegate to handle user input

```swift
override func dayViewDidSelectEventView(_ eventview: EventView) {
  print("Event has been selected: \(eventview.data)")
}

override func dayViewDidLongPressEventView(_ eventView: EventView) {
  print("Event has been longPressed: \(eventView.data)")
}
```
## Localization
CalendarKit supports localization and uses iOS default locale to display month and day names. First day of the week is also selected according to iOS locale. Here are few examples:

<img src="https://cloud.githubusercontent.com/assets/8013017/22315259/bda72b46-e376-11e6-8d0b-20cb5fa2dc95.png" alt="Finnish" width="320">
<br>
<img src="https://cloud.githubusercontent.com/assets/8013017/22315567/8ba5f9c2-e378-11e6-860d-b94e87a2a45c.PNG" alt="German" width="320">
<br>
<img src="https://cloud.githubusercontent.com/assets/8013017/22315600/c87e826a-e378-11e6-9280-732982b42077.PNG" alt="Norwegian" width="320">

## Styles
CalendarKit's look can easily be customized. Just new `CalendarStyle` object to `DayView`'s `updateStyle` method:
```Swift
let style = CalendarStyle()
style.backgroundColor = UIColor.black
dayView.updateStyle(style)
```
<img src="https://cloud.githubusercontent.com/assets/8013017/22717895/a2a63a66-edae-11e6-8611-727348598f09.png" alt="Finnish" width="320">
<img src="https://cloud.githubusercontent.com/assets/8013017/22717896/a2a6c6f2-edae-11e6-8ac3-d9add3d61fb9.png" alt="German" width="320">

## Requirements

- iOS 9.0+
- Swift 3.0+

## Dependencies
- **[Neon](https://github.com/mamaral/Neon)** is used for declarative layout
- **[DateTools](https://github.com/MatthewYork/DateTools)** is used for date manipulation
- **[DynamicColor](https://github.com/yannickl/DynamicColor)** is used to update the colors of Events

## Roadmap
CalendarKit is under development, API can and will be changed.
- [ ] Improve customization
- [ ] Landscape support
- [ ] Add to Carthage
- [ ] Documentation

## Author

Richard Topchii

## License

**CalendarKit** is available under the MIT license. See the LICENSE file for more info.
