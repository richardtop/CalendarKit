import UIKit

open class MonthViewController: UIViewController, EventDataSource, MonthViewDelegate {
    // MARK: - Properties

    public var dataSource: EventDataSource? {
        get {
            return monthView.dataSource
        }
        set(value) {
            monthView.dataSource = value
        }
    }

    public var delegate: MonthViewDelegate? {
        get {
            return monthView.delegate
        }
        set(value) {
            monthView.delegate = value
        }
    }

    public var calendar = Calendar.autoupdatingCurrent {
        didSet {
            monthView.calendar = calendar
        }
    }

    // MARK: - Lifecycle Methods

    override open func loadView() {
        super.loadView()
        view = monthView
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        view.tintColor = SystemColors.systemRed
        delegate = self
        dataSource = self
        monthView.reloadData()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        monthView.scrollToFirstEventIfNeeded()
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { [weak self] _ in
            self?.monthView.frame = CGRect(origin: .zero, size: size)
            self?.monthView.layoutSubviews()
        } completion: { [weak self] _ in
            self?.monthView.frame = CGRect(origin: .zero, size: size)
            self?.monthView.layoutSubviews()

            self?.monthView.monthCollectionView.reloadAndResetLocation()
        }
    }

    // MARK: - UI Elements

    public lazy var monthView = MonthView()

    // MARK: - CalendarKit API

    public func eventsForDate(_: Date) -> [EventDescriptor] {
        return [EventDescriptor]()
    }

    // MARK: - MonthViewDelegate

    public func monthViewDidSelectEventView(_: EventView) {}

    public func monthViewDidLongPressEventView(_: EventView) {}

    public func monthView(monthView _: MonthView, didTapTimelineAt _: Date) {}

    public func monthView(monthView _: MonthView, didLongPressTimelineAt _: Date) {}

    public func monthViewDidBeginDragging(monthView _: MonthView) {}

    public func monthViewDidTransitionCancel(monthView _: MonthView) {}

    public func monthView(monthView _: MonthView, willMoveTo _: Date) {}

    public func monthView(monthView _: MonthView, didMoveTo _: Date) {}

    public func monthView(monthView _: MonthView, didUpdate _: EventDescriptor) {}
}
