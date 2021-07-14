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
  public static var secondarySystemBackground: UIColor {
    if #available(iOS 13, *) {
      return .secondarySystemBackground
    }
    return UIColor(white: 247/255, alpha: 1)
  }
  public static var systemRed: UIColor {
    if #available(iOS 13, *) {
      return .systemRed
    }
    return .red
  }
  public static var systemBlue: UIColor {
    if #available(iOS 13, *) {
      return .systemBlue
    }
    return .blue
  }
  public static var systemGray4: UIColor {
    if #available(iOS 13, *) {
      return .systemGray4
    }
    return UIColor(red: 209/255,
                   green: 209/255,
                   blue: 213/255, alpha: 1)
  }
  public static var systemSeparator: UIColor {
    if #available(iOS 13, *) {
      return .opaqueSeparator
    }
    return UIColor(red: 198/255,
                   green: 198/255,
                   blue: 200/255, alpha: 1)
  }
}

extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 08) & 0xff) / 255,
            blue: CGFloat((hex >> 00) & 0xff) / 255,
            alpha: alpha
        )
    }
}
