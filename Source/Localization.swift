import Foundation

extension Bundle {
  static var localizationBundle: Bundle {
    // When installed via the Swift Package Mananger, the bundle name is "CalendarKit_CalendarKit",
    // via CocoaPods - "CalendarKit"
    let bundleNames = ["CalendarKit_CalendarKit", "CalendarKit"]
    
    let candidates = [
      // Bundle should be present here when the package is linked into an App.
      Bundle.main.resourceURL,
      
      // Bundle should be present here when the package is linked into a framework.
      Bundle(for: DayViewController.self).resourceURL,
      
      // For command-line tools.
      Bundle.main.bundleURL,
    ]
    
    for candidate in candidates {
      for bundleName in bundleNames {
        let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
        if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
          return bundle
        }
      }
    }
    return Bundle.main
  }
}

func localizedString(_ key: String) -> String {
  return Bundle.localizationBundle.localizedString(forKey: key,
                                                   value: nil,
                                                   table: nil)
}
