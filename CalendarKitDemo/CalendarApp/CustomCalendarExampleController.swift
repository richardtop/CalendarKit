import UIKit
import CalendarKit

class CustomCalendarExampleController: DayViewController {
  
  var data = [["Breakfast at Tiffany's",
               "New York, 5th avenue"],
              
              ["Workout",
               "Tufteparken"],
              
              ["Meeting with Alex",
               "Home",
               "Oslo, Tjuvholmen"],
              
              ["Beach Volleyball",
               "Ipanema Beach",
               "Rio De Janeiro"],
              
              ["WWDC",
               "Moscone West Convention Center",
               "747 Howard St"],
              
              ["Google I/O",
               "Shoreline Amphitheatre",
               "One Amphitheatre Parkway"],
              
              ["✈️️ to Svalbard ❄️️❄️️❄️️❤️️",
               "Oslo Gardermoen"],
              
              ["💻📲 Developing CalendarKit",
               "🌍 Worldwide"],
              
              ["Software Development Lecture",
               "Mikpoli MB310",
               "Craig Federighi"],
              
  ]
  
  var generatedEvents = [EventDescriptor]()
  var alreadyGeneratedSet = Set<Date>()
  
  var colors = [UIColor.blue,
                UIColor.yellow,
                UIColor.green,
                UIColor.red]

  private lazy var rangeFormatter: DateIntervalFormatter = {
    let fmt = DateIntervalFormatter()
    fmt.dateStyle = .none
    fmt.timeStyle = .short

    return fmt
  }()

  override func loadView() {
    calendar.timeZone = TimeZone(identifier: "Europe/Paris")!

    dayView = DayView(calendar: calendar)
    view = dayView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "CalendarKit Demo"
    navigationController?.navigationBar.isTranslucent = false
    dayView.autoScrollToFirstEvent = true
    reloadData()
  }
  
  // MARK: EventDataSource
  
  override func eventsForDate(_ date: Date) -> [EventDescriptor] {
    if !alreadyGeneratedSet.contains(date) {
      alreadyGeneratedSet.insert(date)
      generatedEvents.append(contentsOf: generateEventsForDate(date))
    }
    return generatedEvents
  }
  
  private func generateEventsForDate(_ date: Date) -> [EventDescriptor] {
    var workingDate = Calendar.current.date(byAdding: .hour, value: Int.random(in: 1...15), to: date)!
    var events = [Event]()
    
    for i in 0...4 {
      let event = Event()

      let duration = Int.random(in: 60 ... 160)
      event.startDate = workingDate
      event.endDate = Calendar.current.date(byAdding: .minute, value: duration, to: workingDate)!

      var info = data[Int(arc4random_uniform(UInt32(data.count)))]
      
      let timezone = dayView.calendar.timeZone
      print(timezone)

      info.append(rangeFormatter.string(from: event.startDate, to: event.endDate))
      event.text = info.reduce("", {$0 + $1 + "\n"})
      event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
      event.isAllDay = Int(arc4random_uniform(2)) % 2 == 0
      
      // Event styles are updated independently from CalendarStyle
      // hence the need to specify exact colors in case of Dark style
      if #available(iOS 12.0, *) {
        if traitCollection.userInterfaceStyle == .dark {
          event.textColor = textColorForEventInDarkTheme(baseColor: event.color)
          event.backgroundColor = event.color.withAlphaComponent(0.6)
        }
      }
      
      events.append(event)
      
      let nextOffset = Int.random(in: 40 ... 250)
      workingDate = Calendar.current.date(byAdding: .minute, value: nextOffset, to: workingDate)!
      event.userInfo = String(i)
    }

    print("Events for \(date)")
    return events
  }
  
  private func textColorForEventInDarkTheme(baseColor: UIColor) -> UIColor {
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    return UIColor(hue: h, saturation: s * 0.3, brightness: b, alpha: a)
  }
  
  // MARK: DayViewDelegate
  
  private var createdEvent: EventDescriptor?
  
  override func dayViewDidSelectEventView(_ eventView: EventView) {
    guard let descriptor = eventView.descriptor as? Event else {
      return
    }
    print("Event has been selected: \(descriptor) \(String(describing: descriptor.userInfo))")
  }
  
  override func dayViewDidLongPressEventView(_ eventView: EventView) {
    guard let descriptor = eventView.descriptor as? Event else {
      return
    }
    endEventEditing()
    print("Event has been longPressed: \(descriptor) \(String(describing: descriptor.userInfo))")
    beginEditing(event: descriptor, animated: true)
    print(Date())
  }
  
  override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
    endEventEditing()
    print("Did Tap at date: \(date)")
  }
  
  override func dayViewDidBeginDragging(dayView: DayView) {
    print("DayView did begin dragging")
  }
  
  override func dayView(dayView: DayView, willMoveTo date: Date) {
    print("DayView = \(dayView) will move to: \(date)")
  }
  
  override func dayView(dayView: DayView, didMoveTo date: Date) {
    print("DayView = \(dayView) did move to: \(date)")
  }
  
  override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
    print("Did long press timeline at date \(date)")
    // Cancel editing current event and start creating a new one
    endEventEditing()
    let event = generateEventNearDate(date)
    print("Creating a new event")
    create(event: event, animated: true)
    createdEvent = event
  }
  
  private func generateEventNearDate(_ date: Date) -> EventDescriptor {
    let duration = Int(arc4random_uniform(160) + 60)
    let startDate = Calendar.current.date(byAdding: .minute, value: -Int(CGFloat(duration) / 2), to: date)!
    let event = Event()

    event.startDate = startDate
    event.endDate = Calendar.current.date(byAdding: .minute, value: duration, to: startDate)!
    
    var info = data[Int(arc4random_uniform(UInt32(data.count)))]

    info.append(rangeFormatter.string(from: event.startDate, to: event.endDate))
    event.text = info.reduce("", {$0 + $1 + "\n"})
    event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
    event.editedEvent = event
    
    // Event styles are updated independently from CalendarStyle
    // hence the need to specify exact colors in case of Dark style
    if #available(iOS 12.0, *) {
      if traitCollection.userInterfaceStyle == .dark {
        event.textColor = textColorForEventInDarkTheme(baseColor: event.color)
        event.backgroundColor = event.color.withAlphaComponent(0.6)
      }
    }
    return event
  }
  
  override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
    print("did finish editing \(event)")
    print("new startDate: \(event.startDate) new endDate: \(event.endDate)")
    
    if let _ = event.editedEvent {
      event.commitEditing()
    }
    
    if let createdEvent = createdEvent {
      createdEvent.editedEvent = nil
      generatedEvents.append(createdEvent)
      self.createdEvent = nil
      endEventEditing()
    }
    
    reloadData()
  }
}
