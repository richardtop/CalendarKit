import UIKit

// MARK: - Protocol

protocol MonthCollectionViewDelegate: AnyObject {
    func daySelected(_ date: Date)
}

public class MonthCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties

    public var date = Date()
    private var style = DayHeaderStyle()

    weak var dataSource: EventDataSource?

    var selectedDate = Date()
    var selectedIndexPath: IndexPath?

    weak var delegate: MonthCollectionViewDelegate?

    // MARK: - Initialize

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeViews()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeViews()
    }

    public init(calendar _: Calendar = Calendar.autoupdatingCurrent) {
        super.init(frame: CGRect.zero)
        initializeViews()
    }

    private func initializeViews() {
        addSubview(collectionView)
        collectionView.reloadData()
    }

    // MARK: - UI Elements

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MonthCollectionViewCell.self, forCellWithReuseIdentifier: "monthCollectionViewCell")
        collectionView.register(MonthSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")

        collectionView.backgroundColor = style.backgroundColor

        return collectionView
    }()

    // MARK: - Set Up UI

    override public var intrinsicContentSize: CGSize {
        let numberOfCells = (date.daysInCurrentMonth ?? 0) + (date.firstDayOfMonth?.weekday ?? 0) - 1
        let numberOfRows = ceil(Double(numberOfCells) / 7.0)
        return CGSize(width: 0, height: numberOfRows * 70 + 32)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: intrinsicContentSize.height)

        if collectionView.numberOfSections == 12,
           let attributes = collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: date.month - 1)) {
            var offsetY = attributes.frame.origin.y - collectionView.contentInset.top
            if #available(iOS 11.0, *) {
                offsetY -= collectionView.safeAreaInsets.top
            }
            collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
        }
    }

    // MARK: - CollectionView Methods

    public func select(_ date: Date) {
        let indexOfFirstDate = (date.firstDayOfMonth?.weekday ?? 0) - 1
        let newSelectedIndexPath = IndexPath(row: date.day + indexOfFirstDate - 1, section: date.month - 1)

        guard let oldSelectedIndexPath = selectedIndexPath else { return }
        selectedDate = date
        selectedIndexPath = newSelectedIndexPath
        collectionView.reloadItems(at: [oldSelectedIndexPath, newSelectedIndexPath])
    }

    public func reloadAndResetLocation() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData {
                self?.layoutSubviews()
            }
        }
    }

    public func numberOfSections(in _: UICollectionView) -> Int {
        return 12
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dateOfSection = Date.from(year: date.year, month: section + 1, day: 1)
        return ((dateOfSection?.firstDayOfMonth?.weekday ?? 0) - 1) + (dateOfSection?.daysInCurrentMonth ?? 0)
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? MonthSectionHeader else { return UICollectionReusableView() }
            guard let dateOfSection = Date.from(year: date.year, month: indexPath.section + 1, day: 1) else { return sectionHeader }
            sectionHeader.date = dateOfSection
            return sectionHeader
        }
        return UICollectionReusableView()
    }

    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 32)
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: bounds.width / 7, height: 70)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "monthCollectionViewCell", for: indexPath) as? MonthCollectionViewCell else { return UICollectionViewCell() }

        cell.updateStyle(style.daySelector)

        guard let dateOfSection = Date.from(year: date.year, month: indexPath.section + 1, day: 1) else { return cell }

        let indexOfFirstDate = (dateOfSection.firstDayOfMonth?.weekday ?? 0) - 1
        if indexPath.row >= indexOfFirstDate {
            let dateOfRow = Date.from(year: dateOfSection.year, month: dateOfSection.month, day: indexPath.row - indexOfFirstDate + 1) ?? Date()
            cell.date = dateOfRow
            cell.hasEvent = dataSource?.eventsForDate(dateOfRow).isEmpty == false
            cell.dateLabel.selected = dateOfRow.compare(to: selectedDate)
            if dateOfRow.compare(to: selectedDate) { selectedIndexPath = indexPath }
        } else {
            cell.date = nil
        }

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedIndexPath = selectedIndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? MonthCollectionViewCell,
              let dateOfCell = cell.date else { return }
        selectedDate = dateOfCell
        collectionView.reloadItems(at: [selectedIndexPath, indexPath])
        self.selectedIndexPath = indexPath

        delegate?.daySelected(selectedDate)
    }
}

extension UICollectionView {
    func reloadData(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() }) { _ in completion() }
    }
}

// MARK: - MonthCollectionViewCell

public class MonthCollectionViewCell: UICollectionViewCell {
    private var style = DaySelectorStyle()

    public var date: Date? {
        didSet {
            if let date = date {
                separatorLine.isHidden = false
                dateLabel.isHidden = false
                eventIndicator.isHidden = false

                dateLabel.date = date
            } else {
                separatorLine.isHidden = true
                dateLabel.isHidden = true
                eventIndicator.isHidden = true
            }
        }
    }

    var hasEvent: Bool = false

    lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.isHidden = (date == nil)
        return view
    }()

    lazy var dateLabel: DateLabel = {
        let label = DateLabel()
        label.updateStyle(style)
        if let date = date {
            label.isHidden = false
            label.date = date
        } else {
            label.isHidden = true
        }
        return label
    }()

    var eventIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    public func updateStyle(_ newStyle: DaySelectorStyle) {
        style = newStyle
        dateLabel.updateStyle(style)
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.selected = false
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = style.inactiveBackgroundColor
        contentView.backgroundColor = .clear

        separatorLine.removeFromSuperview()
        dateLabel.removeFromSuperview()
        eventIndicator.removeFromSuperview()

        contentView.addSubview(separatorLine)
        contentView.addSubview(dateLabel)
        contentView.addSubview(eventIndicator)

        separatorLine.frame = CGRect(x: -1, y: layoutMargins.top, width: bounds.width + 2, height: 0.5)
        dateLabel.frame = CGRect(x: (bounds.width - 35) / 2, y: separatorLine.frame.maxY + 6, width: 35, height: 35)
        eventIndicator.frame = CGRect(x: (bounds.width - 10) / 2, y: dateLabel.frame.maxY + 4, width: 10, height: 10)
        eventIndicator.isHidden = !hasEvent || date == nil
    }
}

// MARK: - MonthSectionHeader

class MonthSectionHeader: UICollectionReusableView {
    private var style = DaySelectorStyle()

    public var date: Date? {
        didSet {
            label.textColor = (date?.month == Date().month) ? style.todayInactiveTextColor : style.inactiveTextColor
            if let date = date { label.text = "\(date.monthName) \(date.year)" }
        }
    }

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = style.todayFont
        label.sizeToFit()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
    }

    required init?(coder _: NSCoder) {
        super.init(coder: coder)

        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
    }
}
