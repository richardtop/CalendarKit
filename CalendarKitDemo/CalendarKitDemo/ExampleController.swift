import UIKit
import CalendarKit
import DateToolsSwift

enum SelectedStyle {
  case Dark
  case Light
}

class ExampleController: DayViewController, DatePickerControllerDelegate {

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
                UIColor.green,
                UIColor.red]

  var currentStyle = SelectedStyle.Light

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "CalendarKit Demo"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Dark",
                                                        style: .done,
                                                        target: self,
                                                        action: #selector(ExampleController.changeStyle))
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Change Date",
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(ExampleController.presentDatePicker))
    navigationController?.navigationBar.isTranslucent = false
    dayView.autoScrollToFirstEvent = true
    reloadData()
  }

  @objc func changeStyle() {
    var title: String!
    var style: CalendarStyle!

    if currentStyle == .Dark {
      currentStyle = .Light
      title = "Dark"
      style = StyleGenerator.defaultStyle()
    } else {
      title = "Light"
      style = StyleGenerator.darkStyle()
      currentStyle = .Dark
    }
    updateStyle(style)
    navigationItem.rightBarButtonItem!.title = title
    navigationController?.navigationBar.barTintColor = style.header.backgroundColor
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:style.header.swipeLabel.textColor]
    reloadData()
  }

  @objc func presentDatePicker() {
    let picker = DatePickerController()
    picker.date = dayView.state!.selectedDate
    picker.delegate = self
    let navC = UINavigationController(rootViewController: picker)
    navigationController?.present(navC, animated: true, completion: nil)
  }

  func datePicker(controller: DatePickerController, didSelect date: Date?) {
    if let date = date {
      dayView.state?.move(to: date)
    }
    controller.dismiss(animated: true, completion: nil)
  }

  // MARK: EventDataSource

  override func eventsForDate(_ date: Date) -> [EventDescriptor] {
    var date = date.add(TimeChunk.dateComponents(hours: Int(arc4random_uniform(10) + 5)))
    var events = [Event]()

    for i in 0...5 {
      let event = Event()
      let duration = Int(arc4random_uniform(160) + 60)
      let datePeriod = TimePeriod(beginning: date,
                                  chunk: TimeChunk.dateComponents(minutes: duration))

      event.datePeriod = datePeriod
      var info = data[Int(arc4random_uniform(UInt32(data.count)))]
      info.append("\(datePeriod.beginning!.format(with: "dd.MM.YYYY"))")
      info.append("\(datePeriod.beginning!.format(with: "HH:mm")) - \(datePeriod.end!.format(with: "HH:mm"))")
      event.text = info.reduce("", {$0 + $1 + "\n"})
      event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
      
      // Event styles are updated independently from CalendarStyle
      // hence the need to specify exact colors in case of Dark style
      if currentStyle == .Dark {
        event.textColor = textColorForEventInDarkTheme(baseColor: event.color)
        event.backgroundColor = event.color.withAlphaComponent(0.6)
      }
      
      events.append(event)

      let nextOffset = Int(arc4random_uniform(250) + 40)
      date = date.add(TimeChunk.dateComponents(minutes: nextOffset))
      event.userInfo = String(i)
    }

    return events
  }
  
  private func textColorForEventInDarkTheme(baseColor: UIColor) -> UIColor {
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    return UIColor(hue: h, saturation: s * 0.3, brightness: b, alpha: a)
  }

  // MARK: DayViewDelegate

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
    print("Event has been longPressed: \(descriptor) \(String(describing: descriptor.userInfo))")
  }

  override func dayView(dayView: DayView, willMoveTo date: Date) {
//    print("DayView = \(dayView) will move to: \(date)")
  }
  
  override func dayView(dayView: DayView, didMoveTo date: Date) {
//    print("DayView = \(dayView) did move to: \(date)")
  }
}
