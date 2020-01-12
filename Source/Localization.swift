import Foundation

extension Bundle {
  static var localizationBundle: Bundle? {
    let bundle = Bundle(for: DayViewController.self)
    guard let bundlePath = bundle.path(forResource: "CalendarKit",
                                       ofType: "bundle"),
      let targetBundle = Bundle(path: bundlePath) else {
        return nil
    }
    return targetBundle
  }
}

func localizedString(_ key: String) -> String {
  return Bundle.localizationBundle?.localizedString(forKey: key,
                                                    value: nil,
                                                    table: nil) ?? key
}
