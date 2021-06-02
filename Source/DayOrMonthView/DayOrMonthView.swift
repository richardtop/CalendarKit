import UIKit

// MARK: - Protocol

public protocol DayOrMonthViewDelegate: AnyObject {
    func dayOrMonthViewDidSelectEventView(_ eventView: EventView)
    func dayOrMonthViewDidLongPressEventView(_ eventView: EventView)
    func dayOrMonthView(dayOrMonthView: DayOrMonthView, didTapTimelineAt date: Date)
    func dayOrMonthView(dayOrMonthView: DayOrMonthView, didLongPressTimelineAt date: Date)
    func dayOrMonthViewDidBeginDragging(dayOrMonthView: DayOrMonthView)
    func dayOrMonthViewDidTransitionCancel(dayOrMonthView: DayOrMonthView)
    func dayOrMonthView(dayOrMonthView: DayOrMonthView, willMoveTo date: Date)
    func dayOrMonthView(dayOrMonthView: DayOrMonthView, didMoveTo date: Date)
    func dayOrMonthView(dayOrMonthView: DayOrMonthView, didUpdate event: EventDescriptor)
}

public class DayOrMonthView: UIView, MonthCollectionViewDelegate, TimelinePagerViewDelegate {
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

    public weak var delegate: DayOrMonthViewDelegate?

    public var timelineScrollOffset: CGPoint {
        return timelinePagerView.timelineScrollOffset
    }

    private static let headerVisibleHeight: CGFloat = 88
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
            dayHeaderView.state = state
            timelinePagerView.state = state
        }
    }

    public var calendar = Calendar.autoupdatingCurrent

    private var style = CalendarStyle()

    private var viewingDayView = true

    // MARK: - Initialize

    public init(calendar: Calendar = Calendar.autoupdatingCurrent) {
        self.calendar = calendar
        dayHeaderView = DayHeaderView(calendar: calendar)
        daySymbolsView = DaySymbolsView(daysInWeek: 7, calendar: calendar)
        timelinePagerView = TimelinePagerView(calendar: calendar)
        monthCollectionView = MonthCollectionView(calendar: calendar)
        super.init(frame: .zero)
        configure()
    }

    override public init(frame: CGRect) {
        dayHeaderView = DayHeaderView(calendar: calendar)
        daySymbolsView = DaySymbolsView(daysInWeek: 7, calendar: calendar)
        timelinePagerView = TimelinePagerView(calendar: calendar)
        monthCollectionView = MonthCollectionView(calendar: calendar)
        super.init(frame: frame)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        dayHeaderView = DayHeaderView(calendar: calendar)
        daySymbolsView = DaySymbolsView(daysInWeek: 7, calendar: calendar)
        timelinePagerView = TimelinePagerView(calendar: calendar)
        monthCollectionView = MonthCollectionView(calendar: calendar)
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        addSubview(stackView)
        stackView.addArrangedSubview(dayHeaderView)
        stackView.addArrangedSubview(daySymbolsView)
        stackView.addArrangedSubview(monthCollectionView)
        stackView.addArrangedSubview(timelinePagerView)
        setUpAutoLayoutConstraints()
        backgroundColor = style.header.backgroundColor

        monthCollectionView.delegate = self
        timelinePagerView.delegate = self

        if state == nil {
            let newState = DayViewState(date: Date(), calendar: calendar)
            newState.move(to: Date())
            state = newState
        }
    }

    private func setUpAutoLayoutConstraints() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        dayHeaderView.translatesAutoresizingMaskIntoConstraints = false
        dayHeaderView.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true

        daySymbolsView.translatesAutoresizingMaskIntoConstraints = false
        daySymbolsView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        daySymbolsView.isHidden = true

        monthCollectionView.translatesAutoresizingMaskIntoConstraints = false
        monthCollectionView.heightAnchor.constraint(equalToConstant: monthCollectionView.intrinsicContentSize.height).isActive = true
        monthCollectionView.isHidden = true
    }

    public func timelinePanGestureRequire(toFail gesture: UIGestureRecognizer) {
        timelinePagerView.timelinePanGestureRequire(toFail: gesture)
    }

    // MARK: - UI Elements

    let stackView = UIStackView()
    public let dayHeaderView: DayHeaderView
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

    // MARK: - Toggle Day/Month Views

    public func toggleDayMonth() {
        viewingDayView.toggle()
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.dayHeaderView.isHidden = (self?.viewingDayView == false)
            self?.daySymbolsView.isHidden = (self?.viewingDayView == true)
            self?.monthCollectionView.isHidden = (self?.viewingDayView == true)
        }
    }

    // MARK: - Select & Edit

    public func move(to date: Date) {
        state?.move(to: date)
        monthCollectionView.select(date)
    }

    public func daySelected(_ date: Date) {
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
        delegate?.dayOrMonthViewDidSelectEventView(eventView)
    }

    public func timelinePagerDidLongPressEventView(_ eventView: EventView) {
        delegate?.dayOrMonthViewDidLongPressEventView(eventView)
    }

    public func timelinePagerDidBeginDragging(timelinePager _: TimelinePagerView) {
        delegate?.dayOrMonthViewDidBeginDragging(dayOrMonthView: self)
    }

    public func timelinePagerDidTransitionCancel(timelinePager _: TimelinePagerView) {
        delegate?.dayOrMonthViewDidTransitionCancel(dayOrMonthView: self)
    }

    public func timelinePager(timelinePager _: TimelinePagerView, willMoveTo date: Date) {
        delegate?.dayOrMonthView(dayOrMonthView: self, willMoveTo: date)
    }

    public func timelinePager(timelinePager _: TimelinePagerView, didMoveTo date: Date) {
        delegate?.dayOrMonthView(dayOrMonthView: self, didMoveTo: date)
        monthCollectionView.select(date)
    }

    public func timelinePager(timelinePager _: TimelinePagerView, didLongPressTimelineAt date: Date) {
        delegate?.dayOrMonthView(dayOrMonthView: self, didLongPressTimelineAt: date)
    }

    public func timelinePager(timelinePager _: TimelinePagerView, didTapTimelineAt date: Date) {
        delegate?.dayOrMonthView(dayOrMonthView: self, didTapTimelineAt: date)
    }

    public func timelinePager(timelinePager _: TimelinePagerView, didUpdate event: EventDescriptor) {
        delegate?.dayOrMonthView(dayOrMonthView: self, didUpdate: event)
    }
}
