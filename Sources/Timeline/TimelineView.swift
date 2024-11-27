import UIKit

public protocol TimelineViewDelegate: AnyObject {
    func timelineView(_ timelineView: TimelineView, didTapAt date: Date)
    func timelineView(_ timelineView: TimelineView, didLongPressAt date: Date)
    func timelineView(_ timelineView: TimelineView, didTap event: EventView)
    func timelineView(_ timelineView: TimelineView, didLongPress event: EventView)
}

public final class TimelineView: UIView {
    public weak var delegate: TimelineViewDelegate?

    public var date = Date() {
        didSet {
            setNeedsLayout()
        }
    }

    private var currentTime: Date {
        Date()
    }

    private var eventViews = [EventView]()
    public private(set) var regularLayoutAttributes = [EventLayoutAttributes]()
    public private(set) var allDayLayoutAttributes = [EventLayoutAttributes]()

    public var layoutAttributes: [EventLayoutAttributes] {
        get {
            allDayLayoutAttributes + regularLayoutAttributes
        }
        set {

            // update layout attributes by separating all-day from non-all-day events
            allDayLayoutAttributes.removeAll()
            regularLayoutAttributes.removeAll()
            for anEventLayoutAttribute in newValue {
                let eventDescriptor = anEventLayoutAttribute.descriptor
                if eventDescriptor.isAllDay {
                    allDayLayoutAttributes.append(anEventLayoutAttribute)
                } else {
                    adjustEventDurationIfNeeded(for: eventDescriptor)
                    regularLayoutAttributes.append(anEventLayoutAttribute)
                }
            }

           // recalculateEventLayout()
          //  decidePositionOfOverlappingEvents()
            prepareEventViews()
            allDayView.events = allDayLayoutAttributes.map { $0.descriptor }
            allDayView.isHidden = allDayLayoutAttributes.count == 0
            allDayView.scrollToBottom()

            setNeedsLayout()
        }
    }
    private var pool = ReusePool<EventView>()

    public var firstEventYPosition: Double? {
        let first = regularLayoutAttributes.sorted{$0.frame.origin.y < $1.frame.origin.y}.first
        guard let firstEvent = first else {return nil}
        let firstEventPosition = firstEvent.frame.origin.y
        let beginningOfDayPosition = dateToY(date)
        return max(firstEventPosition, beginningOfDayPosition)
    }

    private lazy var nowLine: CurrentTimeIndicator = CurrentTimeIndicator()

    private var allDayViewTopConstraint: NSLayoutConstraint?
    public lazy var allDayView: AllDayView = {
        let allDayView = AllDayView(frame: CGRect.zero)

        allDayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(allDayView)

        allDayViewTopConstraint = allDayView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        allDayViewTopConstraint?.isActive = true

        allDayView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        allDayView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true

        return allDayView
    }()

    var allDayViewHeight: Double {
        allDayView.bounds.height
    }

    var style = TimelineStyle()
    private var horizontalEventInset: Double = 3

    public var fullHeight: Double {
        style.verticalInset * 2 + style.verticalDiff * 24
    }

    public var calendarWidth: Double {
        bounds.width - style.leadingInset
    }
    
    public private(set) var is24hClock = true {
        didSet {
            setNeedsDisplay()
        }
    }

    public var calendar: Calendar = Calendar.autoupdatingCurrent {
        didSet {
            eventEditingSnappingBehavior.calendar = calendar
            nowLine.calendar = calendar
            regenerateTimeStrings()
            setNeedsLayout()
        }
    }

    public var eventEditingSnappingBehavior: EventEditingSnappingBehavior = SnapTo15MinuteIntervals() {
        didSet {
            eventEditingSnappingBehavior.calendar = calendar
        }
    }

    private var times: [String] {
        is24hClock ? _24hTimes : _12hTimes
    }

    private lazy var _12hTimes: [String] = TimeStringsFactory(calendar).make12hStrings()
    private lazy var _24hTimes: [String] = TimeStringsFactory(calendar).make24hStrings()

    private func regenerateTimeStrings() {
        let factory = TimeStringsFactory(calendar)
        _12hTimes = factory.make12hStrings()
        _24hTimes = factory.make24hStrings()
    }

    public lazy private(set) var longPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                                           action: #selector(longPress(_:)))

    public lazy private(set) var tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                               action: #selector(tap(_:)))

    private var isToday: Bool {
        calendar.isDateInToday(date)
    }

    // MARK: - Initialization

    public init() {
        super.init(frame: .zero)
        frame.size.height = fullHeight
        configure()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        contentScaleFactor = 1
        layer.contentsScale = 1
        contentMode = .redraw
        backgroundColor = .white
        addSubview(nowLine)

        // Add long press gesture recognizer
        addGestureRecognizer(longPressGestureRecognizer)
        addGestureRecognizer(tapGestureRecognizer)
    }

    // MARK: - Event Handling

    @objc private func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state == .began) {
            // Get timeslot of gesture location
            let pressedLocation = gestureRecognizer.location(in: self)
            if let eventView = findEventView(at: pressedLocation) {
                delegate?.timelineView(self, didLongPress: eventView)
            } else {
                delegate?.timelineView(self, didLongPressAt: yToDate(pressedLocation.y))
            }
        }
    }

    @objc private func tap(_ sender: UITapGestureRecognizer) {
        let pressedLocation = sender.location(in: self)
        if let eventView = findEventView(at: pressedLocation) {
            delegate?.timelineView(self, didTap: eventView)
        } else {
            delegate?.timelineView(self, didTapAt: yToDate(pressedLocation.y))
        }
    }

    private func findEventView(at point: CGPoint) -> EventView? {
        for eventView in allDayView.eventViews {
            let frame = eventView.convert(eventView.bounds, to: self)
            if frame.contains(point) {
                return eventView
            }
        }

        for eventView in eventViews {
            let frame = eventView.frame
            if frame.contains(point) {
                return eventView
            }
        }
        return nil
    }


    /**
     Custom implementation of the hitTest method is needed for the tap gesture recognizers
     located in the AllDayView to work.
     Since the AllDayView could be outside of the Timeline's bounds, the touches to the EventViews
     are ignored.
     In the custom implementation the method is recursively invoked for all of the subviews,
     regardless of their position in relation to the Timeline's bounds.
     */
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in allDayView.subviews {
            if let subSubView = subview.hitTest(convert(point, to: subview), with: event) {
                return subSubView
            }
        }
        return super.hitTest(point, with: event)
    }

    // MARK: - Style

    public func updateStyle(_ newStyle: TimelineStyle) {
        style = newStyle
        allDayView.updateStyle(style.allDayStyle)
        nowLine.updateStyle(style.timeIndicator)

        switch style.dateStyle {
        case .twelveHour:
            is24hClock = false
        case .twentyFourHour:
            is24hClock = true
        default:
            is24hClock = calendar.locale?.uses24hClock ?? Locale.autoupdatingCurrent.uses24hClock
        }

        backgroundColor = style.backgroundColor
        setNeedsDisplay()
    }

    // MARK: - Background Pattern

    public var accentedDate: Date?

    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        var hourToRemoveIndex = -1

        var accentedHour = -1
        var accentedMinute = -1

        if let accentedDate {
            accentedHour = eventEditingSnappingBehavior.accentedHour(for: accentedDate)
            accentedMinute = eventEditingSnappingBehavior.accentedMinute(for: accentedDate)
        }
        let removeHourCloseToNowLine = false
        if isToday && removeHourCloseToNowLine {
            let minute = component(component: .minute, from: currentTime)
            let hour = component(component: .hour, from: currentTime)
            if minute > 39 {
                hourToRemoveIndex = hour + 1
            } else if minute < 21 {
                hourToRemoveIndex = hour
            }
        }

        let mutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        mutableParagraphStyle.lineBreakMode = .byWordWrapping
        mutableParagraphStyle.alignment = .right
        let paragraphStyle = mutableParagraphStyle.copy() as! NSParagraphStyle

        let attributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle,
                          NSAttributedString.Key.foregroundColor: self.style.timeColor,
                          NSAttributedString.Key.font: style.font] as [NSAttributedString.Key : Any]

        let scale = UIScreen.main.scale
        let hourLineHeight = 1 / UIScreen.main.scale

        let center: Double
        if Int(scale) % 2 == 0 {
            center = 1 / (scale * 2)
        } else {
            center = 0
        }

        let offset = 0.5 - center

        for (hour, time) in times.enumerated() {
            let rightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft

            let hourFloat = Double(hour)
            let context = UIGraphicsGetCurrentContext()
            context!.interpolationQuality = .none
            context?.saveGState()
            context?.setStrokeColor(style.separatorColor.cgColor)
            context?.setLineWidth(hourLineHeight)
            let xStart: Double = {
                if rightToLeft {
                    return bounds.width - 53
                } else {
                    return 53
                }
            }()
            let xEnd: Double = {
                if rightToLeft {
                    return 0
                } else {
                    return bounds.width
                }
            }()
            let y = style.verticalInset + hourFloat * style.verticalDiff + offset
            context?.beginPath()
            context?.move(to: CGPoint(x: xStart, y: y))
            context?.addLine(to: CGPoint(x: xEnd, y: y))
            context?.strokePath()
            context?.restoreGState()

            if hour == hourToRemoveIndex { continue }

            let fontSize = style.font.pointSize
            let timeRect: CGRect = {
                var x: Double
                if rightToLeft {
                    x = bounds.width - 53
                } else {
                    x = 2
                }

                return CGRect(x: x,
                              y: hourFloat * style.verticalDiff + style.verticalInset - 7,
                              width: style.leadingInset - 8,
                              height: fontSize + 2)
            }()

            let timeString = NSString(string: time)
            timeString.draw(in: timeRect, withAttributes: attributes)

            if accentedMinute == 0 {
                continue
            }

            if hour == accentedHour {

                var x: Double
                if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft {
                    x = bounds.width - (style.leadingInset + 7)
                } else {
                    x = 2
                }

                let timeRect = CGRect(x: x, y: hourFloat * style.verticalDiff + style.verticalInset - 7     + style.verticalDiff * (Double(accentedMinute) / 60),
                                      width: style.leadingInset - 8, height: fontSize + 2)

                let timeString = NSString(string: ":\(accentedMinute)")

                timeString.draw(in: timeRect, withAttributes: attributes)
            }
        }
    }

    // MARK: - Layout

    override public func layoutSubviews() {
        super.layoutSubviews()
       // recalculateEventLayout()
        decidePositionOfOverlappingEvents()
        layoutEvents()
        layoutNowLine()
        layoutAllDayEvents()
        allDaySeparator()
    }

    private func layoutNowLine() {
        if !isToday {
            nowLine.alpha = 0
        } else {
            bringSubviewToFront(nowLine)
            nowLine.alpha = 1
            let size = CGSize(width: bounds.size.width, height: 20)
            let rect = CGRect(origin: CGPoint.zero, size: size)
            nowLine.date = currentTime
            nowLine.frame = rect
            nowLine.center.y = dateToY(currentTime)
        }
    }

    private func layoutEvents() {
        if eventViews.isEmpty { return }

        for (idx, attributes) in regularLayoutAttributes.enumerated() {
            let descriptor = attributes.descriptor
            let eventView = eventViews[idx]
            eventView.frame = attributes.frame

            var x: Double
            if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft {
                x = bounds.width - attributes.frame.minX - attributes.frame.width
            } else {
                x = attributes.frame.minX
            }

            eventView.frame = CGRect(x: x,
                                     y: attributes.frame.minY,
                                     width: attributes.frame.width - style.eventGap,
                                     height: attributes.frame.height - style.eventGap)
            eventView.updateWithDescriptor(event: descriptor)
        }
    }

    private func layoutAllDayEvents() {
        //add day view needs to be in front of the nowLine
        bringSubviewToFront(allDayView)
    }

    /**
     This will keep the allDayView as a stationary view in its superview

     - parameter yValue: since the superview is a scrollView, `yValue` is the
     `contentOffset.y` of the scroll view
     */
    public func offsetAllDayView(by yValue: Double) {
        if let topConstraint = self.allDayViewTopConstraint {
            topConstraint.constant = yValue
            layoutIfNeeded()
        }
    }

    private func recalculateEventLayout() {

        // only non allDay events need their frames to be set
        let sortedEvents = self.regularLayoutAttributes.sorted { (attr1, attr2) -> Bool in
            let start1 = attr1.descriptor.dateInterval.start
            let start2 = attr2.descriptor.dateInterval.start
          
            return start1 < start2
        }

        var groupsOfEvents = [[EventLayoutAttributes]]()
        var overlappingEvents = [EventLayoutAttributes]()

        for event in sortedEvents {
            if overlappingEvents.isEmpty {
                overlappingEvents.append(event)
                continue
            }

            let longestEvent = overlappingEvents.sorted { (attr1, attr2) -> Bool in
                var period = attr1.descriptor.dateInterval
                let period1 = period.end.timeIntervalSince(period.start)
                period = attr2.descriptor.dateInterval
                let period2 = period.end.timeIntervalSince(period.start)

                return period1 > period2
            }
                .first!

            if style.eventsWillOverlap {
                guard let earliestEvent = overlappingEvents.first?.descriptor.dateInterval.start else { continue }
                let dateInterval = getDateInterval(date: earliestEvent)
                if event.descriptor.dateInterval.contains(dateInterval.start) {
                    overlappingEvents.append(event)
                    continue
                }
            } else {
                let lastEvent = overlappingEvents.last!
                
                // Create new intervals without seconds
                let longestEventInterval = DateInterval(start: removeSeconds(from: longestEvent.descriptor.dateInterval.start),
                                                        end: removeSeconds(from: longestEvent.descriptor.dateInterval.end))
                let eventInterval = DateInterval(start: removeSeconds(from: event.descriptor.dateInterval.start),
                                                 end: removeSeconds(from: event.descriptor.dateInterval.end))
                let lastEventInterval = DateInterval(start: removeSeconds(from: lastEvent.descriptor.dateInterval.start),
                                                     end: removeSeconds(from: lastEvent.descriptor.dateInterval.end))
                
                if (longestEventInterval.intersects(eventInterval) &&
                    (longestEventInterval.end != eventInterval.start || style.eventGap <= 0.0)) ||
                    (lastEventInterval.intersects(eventInterval) &&
                     (lastEventInterval.end != eventInterval.start || style.eventGap <= 0.0)) {
                    overlappingEvents.append(event)
                    continue
                }
            }
            groupsOfEvents.append(overlappingEvents)
            overlappingEvents = [event]
        }

        groupsOfEvents.append(overlappingEvents)
        overlappingEvents.removeAll()

        for overlappingEvents in groupsOfEvents {
            let totalCount = Double(overlappingEvents.count)
            for (index, event) in overlappingEvents.enumerated() {
                let startY = dateToY(event.descriptor.dateInterval.start)
                let endY = dateToY(event.descriptor.dateInterval.end)
                let floatIndex = Double(index)
                let x = style.leadingInset + floatIndex / totalCount * calendarWidth
                let equalWidth = calendarWidth / totalCount
                event.frame = CGRect(x: x, y: startY, width: equalWidth, height: endY - startY)
            }
        }
    }

    func decidePositionOfOverlappingEvents() {
        let sortedEvents = self.regularLayoutAttributes.sorted { (attr1, attr2) -> Bool in
            let start1 = attr1.descriptor.dateInterval.start
            let start2 = attr2.descriptor.dateInterval.start
            if (start1 == start2) {
                print("How to break the nasty tie? for \(attr1) and \(attr2) ?")
            }
            return start1 < start2
        }
        
        //FILL VALUES
        var groupsOfEvents = findOverlappingGroups6(events: sortedEvents)
        
        for overlappingEvents in groupsOfEvents {
            print("Overlapping events: \(overlappingEvents)")

            let totalCount = Double(overlappingEvents.count)
            for (index, event) in overlappingEvents.enumerated() {
                event.startY = dateToY(event.descriptor.dateInterval.start)
                event.endY = dateToY(event.descriptor.dateInterval.end)
               
                let floatIndex = Double(index)
                let equalWidth = calendarWidth / totalCount
                
                let x = style.leadingInset + floatIndex / totalCount * calendarWidth
                
                var startX = HorizontalPosition(x: x, maxX: x + equalWidth, width: equalWidth, overlappingCount: overlappingEvents.count, positionInOverlappingGroup: index + 1)
                
                event.startXs.append(startX)
            }
        }

        //USE VALUES DYNAMICALLY BASED ON THE closestEarlierOverlappingEvent
        let nastyOverlappingEvents = findOverlappingGroups5(events: sortedEvents)
        nastyOverlappingEvents.forEach { nastyGroup in
            let nodeEvent = nastyGroup.first!
            var minX = 0.0
            var maxX = 0.0
            
            if let closestEarlierOverlappingEvent = nastyGroup.filter({ $0.descriptor.dateInterval.start < nodeEvent.descriptor.dateInterval.start })
                .min(by: {
                    abs($0.descriptor.dateInterval.start.timeIntervalSince(nodeEvent.descriptor.dateInterval.start)) < abs($1.descriptor.dateInterval.start.timeIntervalSince(nodeEvent.descriptor.dateInterval.start)) }) {
                print("Nasty Closest earlier event to \(nodeEvent) is \(closestEarlierOverlappingEvent)")
                var startX = closestEarlierOverlappingEvent.startXs.min { lhs, rhs in
                    return lhs.maxX < rhs.maxX
                }!
                
                var endX = nodeEvent.startXs.min { lhs, rhs in
                    return lhs.maxX < rhs.maxX
                }!
                minX = startX.maxX
                maxX = endX.maxX
            } else {
                var startX = nastyGroup[0].startXs.min { lhs, rhs in
                    return lhs.x < rhs.x
                }!
                minX = startX.x
                maxX = startX.maxX
                print("Nasty No earlier date found.")
            }
            //
            // Find the closest later overlapping date
            if let closestLaterOverLappingEvent = nastyGroup.filter({ $0.descriptor.dateInterval.start > nodeEvent.descriptor.dateInterval.start })
                .min(by: { abs($0.descriptor.dateInterval.start.timeIntervalSince(nodeEvent.descriptor.dateInterval.start)) < abs($1.descriptor.dateInterval.start.timeIntervalSince(nodeEvent.descriptor.dateInterval.start)) }) {
                print("Nasty Closest later date to \(nodeEvent) is \(closestLaterOverLappingEvent)")
            } else {
                var endX = nastyGroup[0].startXs.min { lhs, rhs in
                    return lhs.maxX > rhs.maxX
                }!
                maxX = endX.maxX
                print("No later date found.")
            }
            //
            nodeEvent.frame = CGRect(x: minX, y: nodeEvent.startY, width: maxX - minX, height: nodeEvent.endY - nodeEvent.startY)
            print("Nasty overlapping events: \(String(describing: nastyGroup))")
        }
    }

    func findOverlappingGroups6(events: [EventLayoutAttributes]) -> [[EventLayoutAttributes]] {
        var result: [[EventLayoutAttributes]] = []
        for i in 0..<events.count {
            var group : [EventLayoutAttributes] = [events[i]]
            for j in 0..<events.count {
                if i != j {
                    if events[i].overlaps(with: events[j]) {
                        group.append(events[j])
                    }
                }
            }
            if group.count > 0 {
                var sortedGroup = group.sorted{ (attr1, attr2) -> Bool in
                    let start1 = attr1.descriptor.dateInterval.start
                    let start2 = attr2.descriptor.dateInterval.start
                    return start1 < start2
                }
                result.append(sortedGroup)
            }
        }
        var sortedResult = result.sorted { group1, group2 -> Bool in
            return group1.count > group2.count
        }
        
        return sortedResult
    }
    //with nodes on top
    func findOverlappingGroups5(events: [EventLayoutAttributes]) -> [[EventLayoutAttributes]] {
        var result: [[EventLayoutAttributes]] = []
        for i in 0..<events.count {
            var group : [EventLayoutAttributes] = [events[i]]
            for j in 0..<events.count {
                if i != j {
                    if events[i].overlaps(with: events[j]) {
                        group.append(events[j])
                    }
                }
            }
            if group.count > 0 {
                var sortedGroup = group.dropFirst().sorted{ (attr1, attr2) -> Bool in
                    let start1 = attr1.descriptor.dateInterval.start
                    let start2 = attr2.descriptor.dateInterval.start
                    return start1 < start2
                }
                sortedGroup.insert(group.first!, at: 0)
                result.append(sortedGroup)
            }
        }
        var sortedResult = result.sorted { group1, group2 -> Bool in
            let start1 = group1[0].descriptor.dateInterval.start
            let start2 = group2[0].descriptor.dateInterval.start
            return start1 < start2
        }
        
        return sortedResult
    }
    
    private func prepareEventViews() {
        pool.enqueue(views: eventViews)
        eventViews.removeAll()
        for _ in regularLayoutAttributes {
            let newView = pool.dequeue()
            if newView.superview == nil {
                addSubview(newView)
            }
            eventViews.append(newView)
        }
    }

    public func prepareForReuse() {
        pool.enqueue(views: eventViews)
        eventViews.removeAll()
        setNeedsDisplay()
    }

    // MARK: - Helpers

    public func dateToY(_ date: Date) -> Double {
        let provisionedDate = date.dateOnly(calendar: calendar)
        let timelineDate = self.date.dateOnly(calendar: calendar)
        var dayOffset: Double = 0
        if provisionedDate > timelineDate {
            // Event ending the next day
            dayOffset += 1
        } else if provisionedDate < timelineDate {
            // Event starting the previous day
            dayOffset -= 1
        }
        let fullTimelineHeight = 24 * style.verticalDiff
        let hour = component(component: .hour, from: date)
        let minute = component(component: .minute, from: date)
        let hourY = Double(hour) * style.verticalDiff + style.verticalInset
        let minuteY = Double(minute) * style.verticalDiff / 60
        return hourY + minuteY + fullTimelineHeight * dayOffset
    }

    public func yToDate(_ y: Double) -> Date {
        let timeValue = y - style.verticalInset
        var hour = Int(timeValue / style.verticalDiff)
        let fullHourPoints = Double(hour) * style.verticalDiff
        let minuteDiff = timeValue - fullHourPoints
        let minute = Int(minuteDiff / style.verticalDiff * 60)
        var dayOffset = 0
        if hour > 23 {
            dayOffset += 1
            hour -= 24
        } else if hour < 0 {
            dayOffset -= 1
            hour += 24
        }
        let offsetDate = calendar.date(byAdding: DateComponents(day: dayOffset),
                                       to: date)!
        let newDate = calendar.date(bySettingHour: hour,
                                    minute: minute.clamped(to: 0...59),
                                    second: 0,
                                    of: offsetDate)
        return newDate!
    }

    private func component(component: Calendar.Component, from date: Date) -> Int {
        calendar.component(component, from: date)
    }

    private func getDateInterval(date: Date) -> DateInterval {
        let earliestEventMintues = component(component: .minute, from: date)
        let splitMinuteInterval = style.splitMinuteInterval
        let minute = component(component: .minute, from: date)
        let minuteRange = (minute / splitMinuteInterval) * splitMinuteInterval
        let beginningRange = calendar.date(byAdding: .minute, value: -(earliestEventMintues - minuteRange), to: date)!
        let endRange = calendar.date(byAdding: .minute, value: splitMinuteInterval, to: beginningRange)!
        return DateInterval(start: beginningRange, end: endRange)
    }
    
    /// This change ensures that events shorter than 20 minutes are displayed with a minimum duration of 20 minutes(so even if the event has actual duration of 5 minutes it will be set to 20).In the current event layout system, very short events (less than 20 minutes) are visually difficult to interact with and can cause layout issues, such as overlapping or appearing too small in the timeline view.By extending the duration of such short events to 20 minutes, we provide a more usable visual representation and prevent UI bugs where these events might be misaligned or invisible due to their small height. This change is made within the layoutAttributes setter to intercept and adjust the duration before the events are laid out.
    private func adjustEventDurationIfNeeded(for eventDescriptor: EventDescriptor) {
        let eventDuration = eventDescriptor.dateInterval.end.timeIntervalSince(eventDescriptor.dateInterval.start) / 60.0
        let shortEventDuration = style.verticalDiff * 0.2
        if eventDuration < shortEventDuration {
            let newEndDate = calendar.date(byAdding: .minute, value: Int(shortEventDuration), to: eventDescriptor.dateInterval.start)
            eventDescriptor.dateInterval = DateInterval(start: eventDescriptor.dateInterval.start, end: newEndDate!)
        }
    }
    
    private func allDaySeparator() {
        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = UIColor.gray.withAlphaComponent(0.5)

        allDayView.addSubview(bottomLine)

        NSLayoutConstraint.activate([
            bottomLine.heightAnchor.constraint(equalToConstant: 2),
            bottomLine.leadingAnchor.constraint(equalTo: allDayView.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: allDayView.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: allDayView.bottomAnchor),
        ])
    }
}

extension EventLayoutAttributes {
    //ExcludingBounds
    func overlaps(with other: EventLayoutAttributes) -> Bool {
        return self.descriptor.dateInterval.start < other.descriptor.dateInterval.end && self.descriptor.dateInterval.end > other.descriptor.dateInterval.start &&
        self.descriptor.dateInterval.start != other.descriptor.dateInterval.end && self.descriptor.dateInterval.end != other.descriptor.dateInterval.start
    }
/*
func overlaps(with other: EventLayoutAttributes) -> Bool {
        self.descriptor.dateInterval.start =  removeSeconds(from:self.descriptor.dateInterval.start)
        self.descriptor.dateInterval.end =  removeSeconds(from:self.descriptor.dateInterval.end)
        other.descriptor.dateInterval.start =  removeSeconds(from:other.descriptor.dateInterval.start)
        other.descriptor.dateInterval.end =  removeSeconds(from:other.descriptor.dateInterval.end)
        return self.descriptor.dateInterval.intersects(other.descriptor.dateInterval)
    }*/
}

extension Array where Element == CGFloat {
    /// Returns the median value of the array, or `nil` if the array is empty.
    func median() -> CGFloat? {
        guard !self.isEmpty else { return nil }
        
        let sortedArray = self.sorted()
        let count = sortedArray.count
        
        if count % 2 == 1 {
            // Odd count: return the middle element
            return sortedArray[count / 2]
        } else {
            // Even count: return the average of the two middle elements
            let mid1 = sortedArray[count / 2 - 1]
            let mid2 = sortedArray[count / 2]
            return (mid1 + mid2) / 2
        }
    }
}

private func removeSeconds(from date: Date) -> Date {
    let calendar = Calendar.current
    return calendar.date(bySettingHour: calendar.component(.hour, from: date),
                         minute: calendar.component(.minute, from: date),
                         second: 0,
                         of: date) ?? date
}


func doIntervalsOverlapExcludingBounds(_ interval1: DateInterval, _ interval2: DateInterval) -> Bool {
    // Check if intervals overlap excluding start and end
    return interval1.start < interval2.end && interval1.end > interval2.start &&
           interval1.start != interval2.end && interval1.end != interval2.start
}
