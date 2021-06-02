import UIKit

open class DayOrMonthViewController: UIViewController, EventDataSource, DayOrMonthViewDelegate {
    // MARK: - Properties

    public var dataSource: EventDataSource? {
        get {
            return dayOrMonthView.dataSource
        }
        set(value) {
            dayOrMonthView.dataSource = value
        }
    }

    public var delegate: DayOrMonthViewDelegate? {
        get {
            return dayOrMonthView.delegate
        }
        set(value) {
            dayOrMonthView.delegate = value
        }
    }

    public var calendar = Calendar.autoupdatingCurrent {
        didSet {
            dayOrMonthView.calendar = calendar
        }
    }

    // MARK: - Lifecycle Methods

    override open func loadView() {
        super.loadView()
        view = dayOrMonthView
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        view.tintColor = SystemColors.systemRed
        delegate = self
        dataSource = self
        dayOrMonthView.reloadData()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dayOrMonthView.scrollToFirstEventIfNeeded()
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { [weak self] _ in
            self?.dayOrMonthView.frame = CGRect(origin: .zero, size: size)
        } completion: { [weak self] _ in
            self?.dayOrMonthView.frame = CGRect(origin: .zero, size: size)
            self?.dayOrMonthView.monthCollectionView.reloadAndResetLocation()
        }
    }

    // MARK: - UI Elements

    public lazy var dayOrMonthView = DayOrMonthView()

    // MARK: - Toggle Day/Month

    @objc public func toggleDayMonthButtonTapped() {
        dayOrMonthView.toggleDayMonth()
    }

    // MARK: - CalendarKit API

    public func eventsForDate(_: Date) -> [EventDescriptor] {
        return [EventDescriptor]()
    }

    // MARK: - MonthViewDelegate

    public func dayOrMonthViewDidSelectEventView(_: EventView) {}

    public func dayOrMonthViewDidLongPressEventView(_: EventView) {}

    public func dayOrMonthView(dayOrMonthView _: DayOrMonthView, didTapTimelineAt _: Date) {}

    public func dayOrMonthView(dayOrMonthView _: DayOrMonthView, didLongPressTimelineAt _: Date) {}

    public func dayOrMonthViewDidBeginDragging(dayOrMonthView _: DayOrMonthView) {}

    public func dayOrMonthViewDidTransitionCancel(dayOrMonthView _: DayOrMonthView) {}

    public func dayOrMonthView(dayOrMonthView _: DayOrMonthView, willMoveTo _: Date) {}

    public func dayOrMonthView(dayOrMonthView _: DayOrMonthView, didMoveTo _: Date) {}

    public func dayOrMonthView(dayOrMonthView _: DayOrMonthView, didUpdate _: EventDescriptor) {}
}
