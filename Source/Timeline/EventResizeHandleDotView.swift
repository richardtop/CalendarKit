import Foundation
import UIKit

public final class EventResizeHandleDotView: UIView {
  public var borderColor: UIColor? {
    get {
      guard let cgColor = layer.borderColor else {return nil}
      return UIColor(cgColor: cgColor)
    }
    set(value) {
      layer.borderColor = value?.cgColor
    }
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.height / 2
  }
  
  private func configure() {
    clipsToBounds = true
    backgroundColor = .white
    layer.borderWidth = 2
  }
}
