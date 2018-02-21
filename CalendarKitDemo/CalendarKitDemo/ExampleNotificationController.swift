import CalendarKit
import DateToolsSwift

class ExampleNotificationController: UIViewController {
  
  lazy var timelineContainer: TimelineContainer = {
    let timeline = TimelineView()
    timeline.frame.size.height = timeline.fullHeight
    let container = TimelineContainer(timeline)
    container.contentSize = timeline.frame.size
    container.addSubview(timeline)
    container.isUserInteractionEnabled = false
    return container
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .lightGray
    view.addSubview(timelineContainer)
    timelineContainer.timeline.date = Date()
    
    let date = Date()
    let event = Event()
    let duration = 80
    let datePeriod = TimePeriod(beginning: date,
                                chunk: TimeChunk.dateComponents(minutes: duration))
    
    event.startDate = datePeriod.beginning!
    event.endDate = datePeriod.end!

    var info = ["Compliance report"]
    info.append("\(datePeriod.beginning!.format(with: "dd.MM"))")
    info.append("\(datePeriod.beginning!.format(with: "HH:mm")) - \(datePeriod.end!.format(with: "HH:mm"))")
    event.text = info.reduce("", {$0 + $1 + "\n"})
    event.color = .red
    timelineContainer.timeline.eventDescriptors = [event]
    timelineContainer.scrollTo(hour24: 20)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let size = CGSize(width: view.width, height: 140)
    let origin = CGPoint(x: 0, y: view.height/2)
    timelineContainer.frame = CGRect(origin: origin, size: size)
    timelineContainer.scrollTo(hour24: Float(max(Date().hour - 1, 0)))
    
    timelineContainer.layer.cornerRadius = 25
  }
}
