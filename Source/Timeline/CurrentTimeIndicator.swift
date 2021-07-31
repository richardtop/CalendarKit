import UIKit

@objc public final class CurrentTimeIndicator: UIView {
  private let padding : CGFloat = 3
  private let leadingInset: CGFloat = 53

  public var calendar: Calendar = Calendar.autoupdatingCurrent {
    didSet {
      updateDate()
    }
  }

  private weak var timer: Timer?
  @objc private func timerDidFire(_ sender: Timer) {
    date = Date()
  }

  /// Determines if times should be displayed in a 24 hour format. Defaults to the current locale's setting
  public var is24hClock : Bool = true {
    didSet {
      updateDate()
    }
  }

  public var date = Date() {
    didSet {
      updateDate()
    }
  }

  private var timeLabel = UILabel()
  private var circle = UIView()
  private var line = UIView()

  private var style = CurrentTimeIndicatorStyle()

  private lazy var dateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.locale = calendar.locale
    fmt.timeZone = calendar.timeZone

    return fmt
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  private func configure() {
    [timeLabel, circle, line].forEach {
      addSubview($0)
    }
    
    //Allow label to adjust so that am/pm can be displayed if format is changed.
    timeLabel.numberOfLines = 1
    timeLabel.textAlignment = .right
    timeLabel.adjustsFontSizeToFitWidth = true
    timeLabel.minimumScaleFactor = 0.5
    
    //The width of the label is determined by leftInset and padding. 
    //The y position is determined by the line's middle.
    timeLabel.translatesAutoresizingMaskIntoConstraints = false
    timeLabel.widthAnchor.constraint(equalToConstant: leadingInset - (3 * padding)).isActive = true
    timeLabel.trailingAnchor.constraint(equalTo: line.leadingAnchor, constant: -padding).isActive = true
    timeLabel.centerYAnchor.constraint(equalTo: line.centerYAnchor).isActive = true
    timeLabel.baselineAdjustment = .alignCenters
    
    updateStyle(style)
    configureTimer()
    isUserInteractionEnabled = false
  }
  
  private func configureTimer() {
    invalidateTimer()
    let date = Date()
    var components = calendar.dateComponents(Set([.era, .year, .month, .day, .hour, .minute]), from: date)
    components.minute! += 1
    let timerDate = calendar.date(from: components)!
    let newTimer = Timer(fireAt: timerDate,
                  interval: 60,
                  target: self,
                  selector: #selector(timerDidFire(_:)),
                  userInfo: nil,
                  repeats: true)
    RunLoop.current.add(newTimer, forMode: .common)
    timer = newTimer
  }
  
  private func invalidateTimer() {
    timer?.invalidate()
  }
    
  private func updateDate() {
    dateFormatter.dateFormat = is24hClock ? "HH:mm" : "h:mm a"
    dateFormatter.calendar = calendar
    dateFormatter.timeZone = calendar.timeZone
    timeLabel.text = dateFormatter.string(from: date)
    timeLabel.sizeToFit()
    setNeedsLayout()
    configureTimer()
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    line.frame = {
        
        let x: CGFloat
        let rightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        if rightToLeft {
            x = 0
        } else {
            x = leadingInset - padding
        }
        
        return CGRect(x: x, y: bounds.height / 2, width: bounds.width - leadingInset, height: 1)
    }()

    circle.frame = {
        
        let x: CGFloat
        if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft {
            x = bounds.width - leadingInset - 10
        } else {
            x = leadingInset + 1
        }
        
        return CGRect(x: x, y: 0, width: 6, height: 6)
    }()
    circle.center.y = line.center.y
    circle.layer.cornerRadius = circle.bounds.height / 2
  }

  func updateStyle(_ newStyle: CurrentTimeIndicatorStyle) {
    style = newStyle
    timeLabel.textColor = style.color
    timeLabel.font = style.font
    circle.backgroundColor = style.color
    line.backgroundColor = style.color
    
    switch style.dateStyle {
    case .twelveHour:
        is24hClock = false
        break
    case .twentyFourHour:
        is24hClock = true
        break
    default:
        is24hClock = Locale.autoupdatingCurrent.uses24hClock()
        break
    }
  }
  
  public override func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    if newSuperview != nil {
      configureTimer()
    } else {
      invalidateTimer()
    }
  }
}
