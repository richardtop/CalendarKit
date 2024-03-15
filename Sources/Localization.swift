import Foundation

func localizedString(_ key: String) -> String {
    var localizationBundle = Bundle.main
    // When installed via the Swift Package Manager, the bundle name is "CalendarKit_CalendarKit",
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

outer:
    for candidate in candidates {
        for bundleName in bundleNames {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                localizationBundle = bundle
                break outer
            }
        }
    }

    return localizationBundle.localizedString(forKey: key,
                                              value: nil,
                                              table: nil)
}
