import Foundation

public class EventResizeHandleView: UIView {
  public lazy var panGestureRecognizer = UIPanGestureRecognizer()
  public lazy var dotView = EventResizeHandleDotView()

  public var borderColor: UIColor? {
    get {
      return dotView.borderColor
    }
    set(value) {
      dotView.borderColor = value
    }
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configure() {
    addSubview(dotView)
    clipsToBounds = false
    backgroundColor = .clear
    addGestureRecognizer(panGestureRecognizer)
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    let radius: CGFloat = 7
    let centerD = (width - radius) / 2
    let origin = CGPoint(x: centerD, y: centerD)
    let dotSize = CGSize(width: radius, height: radius)
    dotView.frame = CGRect(origin: origin, size: dotSize)
  }
}
