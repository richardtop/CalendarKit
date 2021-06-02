import UIKit

// MARK: - Protocol

public protocol MonthViewDelegate: AnyObject {
    func monthViewDidSelectEventView(_ eventView: EventView)
    func monthViewDidLongPressEventView(_ eventView: EventView)
    func monthView(monthView: MonthView, didTapTimelineAt date: Date)
    func monthView(monthView: MonthView, didLongPressTimelineAt date: Date)
    func monthViewDidBeginDragging(monthView: MonthView)
    func monthViewDidTransitionCancel(monthView: MonthView)
    func monthView(monthView: MonthView, willMoveTo date: Date)
    func monthView(monthView: MonthView, didMoveTo date: Date)
    func monthView(monthView: MonthView, didUpdate event: EventDescriptor)
}

public class MonthView: UIView, MonthCollectionViewDelegate, TimelinePagerViewDelegate {
    // MARK: - Properties

    public weak var dataSource: EventDataSource? {
        get {
            return timelinePagerView.dataSource
        }
        set(value) {
            timelinePagerView.dataSource = value
            monthCollectionView.dataSource = value
        }
    }

    public weak var delegate: MonthViewDelegate?

    public var timelineScrollOffset: CGPoint {
        return timelinePagerView.timelineScrollOffset
    }

    private static let headerVisibleHeight: CGFloat = 25
    public var headerHeight: CGFloat = headerVisibleHeight

    public var autoScrollToFirstEvent: Bool {
        get {
            return timelinePagerView.autoScrollToFirstEvent
        }
        set(value) {
            timelinePagerView.autoScrollToFirstEvent = value
        }
    }

    public var state: DayViewState? {
        didSet {
            timelinePagerView.state = state
        }
    }

    public var calendar = Calendar.autoupdatingCurrent

    private var style = CalendarStyle()

    // MARK: - Initialize

    public init(calendar: Calendar = Calendar.autoupdatingCurrent) {
        self.calendar = calendar
        daySymbolsView = DaySymbolsView(daysInWeek: 7, calendar: calendar)
        timelinePagerView = TimelinePagerView(calendar: calendar)
        monthCollectionView = MonthCollectionView(calendar: calendar)
        super.init(frame: .zero)
        configure()
    }

    override public init(frame: CGRect) {
        daySymbolsView = DaySymbolsView(daysInWeek: 7, calendar: calendar)
        timelinePagerView = TimelinePagerView(calendar: calendar)
        monthCollectionView = MonthCollectionView(calendar: calendar)
        super.init(frame: frame)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        daySymbolsView = DaySymbolsView(daysInWeek: 7, calendar: calendar)
        timelinePagerView = TimelinePagerView(calendar: calendar)
        monthCollectionView = MonthCollectionView(calendar: calendar)
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        addSubview(daySymbolsView)
        addSubview(timelinePagerView)
        addSubview(monthCollectionView)
        backgroundColor = style.header.backgroundColor

        monthCollectionView.delegate = self
        timelinePagerView.delegate = self

        if state == nil {
            let newState = DayViewState(date: Date(), calendar: calendar)
            newState.move(to: Date())
            state = newState
        }
    }

    public func timelinePanGestureRequire(toFail gesture: UIGestureRecognizer) {
        timelinePagerView.timelinePanGestureRequire(toFail: gesture)
    }

    // MARK: - UI Elements

    public let daySymbolsView: DaySymbolsView
    public let monthCollectionView: MonthCollectionView
    public let timelinePagerView: TimelinePagerView

    // MARK: - Update UI

    public func updateStyle(_ newStyle: CalendarStyle) {
        style = newStyle
        backgroundColor = style.header.backgroundColor
        daySymbolsView.updateStyle(style.header.daySymbols)
        timelinePagerView.updateStyle(style.timeline)
    }

    public func scrollTo(hour24: Float, animated: Bool = true) {
        timelinePagerView.scrollTo(hour24: hour24, animated: animated)
    }

    public func scrollToFirstEventIfNeeded(animated: Bool = true) {
        timelinePagerView.scrollToFirstEventIfNeeded(animated: animated)
    }

    public func reloadData() {
        monthCollectionView.collectionView.reloadData()
        timelinePagerView.reloadData()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        daySymbolsView.frame = CGRect(x: 0, y: layoutMargins.top, width: bounds.width, height: headerHeight)

        monthCollectionView.frame = CGRect(x: 0, y: daySymbolsView.frame.maxY, width: bounds.width, height: monthCollectionView.intrinsicContentSize.height)

        let timelinePagerHeight = bounds.height - monthCollectionView.frame.maxY
        timelinePagerView.frame = CGRect(x: 0, y: monthCollectionView.frame.maxY, width: bounds.width, height: timelinePagerHeight)
    }

    // MARK: - Select & Edit Dates

    public func move(to date: Date) {
        state?.move(to: date)
        monthCollectionView.select(date)
    }

    func daySelected(_ date: Date) {
        state?.move(to: date)
    }

    public func create(event: EventDescriptor, animated: Bool = false) {
        timelinePagerView.create(event: event, animated: animated)
    }

    public func beginEditing(event: EventDescriptor, animated: Bool = false) {
        timelinePagerView.beginEditing(event: event, animated: animated)
    }

    public func endEventEditing() {
        timelinePagerView.endEventEditing()
    }

    // MARK: - TimelinePagerViewDelegate

    public func timelinePagerDidSelectEventView(_ eventView: EventView) {
        delegate?.monthViewDidSelectEventView(eventView)
    }

    public func timelinePagerDidLongPressEventView(_ eventView: EventView) {
        delegate?.monthViewDidLongPressEventView(eventView)
    }

    public func timelinePagerDidBeginDragging(timelinePager _: TimelinePagerView) {
        delegate?.monthViewDidBeginDragging(monthView: self)
    }

    public func timelinePagerDidTransitionCancel(timelinePager _: TimelinePagerView) {
        delegate?.monthViewDidTransitionCancel(monthView: self)
    }

    public func timelinePager(timelinePager _: TimelinePagerView, willMoveTo date: Date) {
        delegate?.monthView(monthView: self, willMoveTo: date)
    }

    public func timelinePager(timelinePager _: TimelinePagerView, didMoveTo date: Date) {
        delegate?.monthView(monthView: self, didMoveTo: date)
        monthCollectionView.select(date)
    }

    public func timelinePager(timelinePager _: TimelinePagerView, didLongPressTimelineAt date: Date) {
        delegate?.monthView(monthView: self, didLongPressTimelineAt: date)
    }

    public func timelinePager(timelinePager _: TimelinePagerView, didTapTimelineAt date: Date) {
        delegate?.monthView(monthView: self, didTapTimelineAt: date)
    }

    public func timelinePager(timelinePager _: TimelinePagerView, didUpdate event: EventDescriptor) {
        delegate?.monthView(monthView: self, didUpdate: event)
    }
}
