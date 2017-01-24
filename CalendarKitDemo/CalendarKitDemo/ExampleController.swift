import UIKit
import CalendarKit
import DateTools

class ExampleController: DayViewController {

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

  var colors = [UIColor.blue,
                UIColor.yellow,
                UIColor.black,
                UIColor.green,
                UIColor.red]

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "CalendarKit Demo"
    reloadData()
  }

  // MARK: DayViewDataSource

  override func eventViewsForDate(_ date: Date) -> [EventView] {
    var date = date.add(TimeChunk(seconds: 0, minutes: 0, hours: Int(arc4random_uniform(10) + 5), days: 0, weeks: 0, months: 0, years: 0))
    var events = [EventView]()

    for _ in 0...5 {
      let event = EventView()
      let duration = Int(arc4random_uniform(160) + 60)
      let datePeriod = TimePeriod(beginning: date,
                                  chunk: TimeChunk(seconds: 0, minutes: duration, hours: 0, days: 0, weeks: 0, months: 0, years: 0))

      event.datePeriod = datePeriod
      var info = data[Int(arc4random_uniform(UInt32(data.count)))]
      info.append("\(datePeriod.beginning!.format(with: "HH:mm")!) - \(datePeriod.end!.format(with: "HH:mm")!)")
      event.data = info
      event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
      events.append(event)

      let nextOffset = Int(arc4random_uniform(250) + 40)
      date = date.add(TimeChunk(seconds: 0, minutes: nextOffset, hours: 0, days: 0, weeks: 0, months: 0, years: 0))
    }

    return events
  }

  // MARK: DayViewDelegate

  override func dayViewDidSelectEventView(_ eventview: EventView) {
    
    print("Event has been selected: \(eventview.data)")
  }
  
  override func dayViewDidLongPressEventView(_ eventView: EventView) {
    print("Event has been longPressed: \(eventView.data)")
  }
}
