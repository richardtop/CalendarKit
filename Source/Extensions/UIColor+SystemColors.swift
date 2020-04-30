import UIKit

public enum SystemColors {
  public static var label: UIColor {
    if #available(iOS 13, *) {
      return .label
    }
    return .black
  }
  public static var secondaryLabel: UIColor {
    if #available(iOS 13, *) {
      return .secondaryLabel
    }
    return .lightGray
  }
  public static var systemBackground: UIColor {
    if #available(iOS 13, *) {
      return .systemBackground
    }
    return .white
  }
  public static var systemRed: UIColor {
    if #available(iOS 13, *) {
      return .systemRed
    }
    return .red
  }
}
