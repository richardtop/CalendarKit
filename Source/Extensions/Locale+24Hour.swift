import Foundation

extension Locale {
    
  /// Returns true if this locale uses a 24 hour time format
  ///
  /// - Returns: true if this locale uses a 24 hour time format
  func uses24hClock() -> Bool {
    //[j] is a special-purpose symbol. It must not occur in pattern or skeleton data. Instead, it is reserved for use in skeletons passed to APIs doing flexible date pattern generation. In such a context, it requests the preferred hour format for the locale (h, H, K, or k), as determined by whether h, H, K, or k is used in the standard short time format for the locale. In the implementation of such an API, 'j' must be replaced by h, H, K, or k before beginning a match against availableFormats data. Note that use of 'j' in a skeleton passed to an API is the only way to have a skeleton request a locale's preferred time cycle type (12-hour or 24-hour).
    //http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
        
    let formatter = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: self) ?? ""
    return !formatter.contains("a")
  }
    
}
