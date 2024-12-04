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

            //decidePositionOfOverlappingEvents()
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
                if (longestEvent.descriptor.dateInterval.intersects(event.descriptor.dateInterval) && (longestEvent.descriptor.dateInterval.end != event.descriptor.dateInterval.start || style.eventGap <= 0.0)) ||
                    (lastEvent.descriptor.dateInterval.intersects(event.descriptor.dateInterval) && (lastEvent.descriptor.dateInterval.end != event.descriptor.dateInterval.start || style.eventGap <= 0.0)) {
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
        guard !regularLayoutAttributes.isEmpty else {
            return
        }
        //Sort events by startDateTime. When equal then longest comes first
        let sortedEvents = self.regularLayoutAttributes.sorted { (e1, e2) -> Bool in
            let start1 = e1.descriptor.dateInterval.start
            let start2 = e2.descriptor.dateInterval.start
            if (start1 == start2) {
                print("\(e1) starts at the same time as \(e2) ?")
                return e1.descriptor.dateInterval > e2.descriptor.dateInterval
            }
            return start1 < start2
        }
        // Build trees Where each branch reprsents overlapping events
        let forest = buildEventsForest(sortedEvents: sortedEvents)
        
        for tree in forest {
            //for debugging purposes
            printTree(tree)
            //Traverse the tree and assign for each node it's index in the longest branch it appears on. This value will be used to decide startX
            assignIndexInLongestBranch(tree, longestPath: [])
            //for debugging purposes
            printNodeIndexes(tree)
            
            traverseTree(tree) { node in
                let startY = dateToY(node.value.descriptor.dateInterval.start)
                let endY = dateToY(node.value.descriptor.dateInterval.end)
                let floatIndex = Double(node.indexInLongestBranch)
                
                var startX = 0.0
                var endX = 0.0
                if node.parent == nil {
                    //if earliest node and on the most left then make It's startX at the very beginning.
                    startX = style.leadingInset
                } else {
                    //Make node's startX same as the nearest earlier overlapping event's endX
                    startX = node.parent!.value.frame.maxX
                }
                
                //The width should be all available width divided the count of direct overlaps
                let equalWidth = calendarWidth / Double(node.calculateLongestBranchDepth())
                //If the event is a leaf node then it means that it has no overlaps that it's later than it. Let it expand to the most right.
                if node.children.isEmpty {
                    endX = bounds.width
                } else {
                    //If the event has later overlapping events, then it should leave space for them.
                    endX = startX + equalWidth
                }
                
                node.value.frame = CGRect(x: startX, y: startY, width: endX - startX, height: endY - startY)
            }
        }
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

private class TreeNode<EventLayoutAttributes> {
    var value: EventLayoutAttributes
    var children: [TreeNode] = []
    var parent: TreeNode?
    var indexInLongestBranch = 0
    var longestBranchDepth = 0
    
    init(value: EventLayoutAttributes) {
        self.value = value
    }
    
    func addChild(_ child: TreeNode) {
        children.append(child)
        child.parent = self
    }
    
    func calculateLongestBranchDepth() -> Int {
        self.longestBranchDepth =  distanceToRoot() + longestChildBranch()
        return longestBranchDepth
    }
    
    func distanceToRoot() -> Int {
        var distance = 0
        var currentNode = self
        
        while let parent = currentNode.parent {
            currentNode = parent
            distance += 1
        }
        
        return distance
    }
    
    func longestChildBranch() -> Int {
        if children.isEmpty {
            return 1
        }
        var maxChildOverlap = 0
        for child in children {
            maxChildOverlap = max(maxChildOverlap, child.longestChildBranch())
        }
        return 1 + maxChildOverlap
    }
    
    func traversePostOrder(visitedEnough: inout Bool, visit: (TreeNode) -> Bool) {
        // Traverse all child nodes first
        for child in children {
            child.traversePostOrder(visitedEnough: &visitedEnough, visit: visit)
        }
        // Visit the current node
        if visitedEnough {
            return
        }
        visitedEnough = visit(self)
        
        return
    }
}

private func buildEventsForest(sortedEvents: [EventLayoutAttributes]) -> [TreeNode<EventLayoutAttributes>] {
    //Create an empty forest.
    var forest: [TreeNode<EventLayoutAttributes>] = []
    
    //If not events then return early on.
    guard !sortedEvents.isEmpty else {
        return forest
    }
    //Add the earliest event as the first tree.
    forest.append(TreeNode(value: sortedEvents[0]))
  
    //loop on sorted events and figure out where should they be added in the tree based on overlapping. Otherwise make them plant their own tree.
    for event in sortedEvents[1...] {
        if !addEventToTree(event, to: forest) {
            forest.append(TreeNode(value: event))
        }
    }
    
    //A method used to decide where should an event be added in a tree.
    func addEventToTree(_ event: EventLayoutAttributes, to nodes: [TreeNode<EventLayoutAttributes>]) -> Bool {
        var added = false
        for node in nodes {
            node.traversePostOrder(visitedEnough: &added) { node in
                var overlaps = false
                if event.overlaps(with: node.value) {
                    node.addChild(TreeNode(value: event))
                    overlaps = true
                }
                return overlaps
            }
        }
        return added
    }
    
    return forest
}

private func printTree<EventLayoutAttributes>(_ node: TreeNode<EventLayoutAttributes>, level: Int = 0) {
    let indent = String(repeating: "  ", count: level)
    print("\(indent)- \(node.value)")
    
    for child in node.children {
        printTree(child, level: level + 1)
    }
}

private func traverseTree<EventLayoutAttributes>(_ node: TreeNode<EventLayoutAttributes>, depth: Int = 0, index: Int = 0, calculatePosition: (TreeNode<EventLayoutAttributes>) -> Void) {
    calculatePosition(node)
  
    for (childIndex, child) in node.children.enumerated() {
        traverseTree(child, depth: depth + 1, index: childIndex, calculatePosition: calculatePosition)
    }
}

private func assignIndexInLongestBranch<T>(_ node: TreeNode<T>, longestPath: [TreeNode<T>]) {
    node.indexInLongestBranch = longestPath.count
    var currentLongestPath = longestPath
    currentLongestPath.append(node)
    if node.children.isEmpty {
        return
    }
    for child in node.children {
        assignIndexInLongestBranch(child, longestPath: currentLongestPath)
    }
}

private func printNodeIndexes<T>(_ node: TreeNode<T>) {
    print("Node \(node.value) is at index \(String(describing: node.indexInLongestBranch)) in the longest branch of depth \(node.longestBranchDepth)")
    for child in node.children {
        printNodeIndexes(child)
    }
}

