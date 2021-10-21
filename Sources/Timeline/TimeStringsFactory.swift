import Foundation

struct TimeStringsFactory {
  private let calendar: Calendar
  
  init(_ calendar: Calendar = Calendar.autoupdatingCurrent) {
    self.calendar = calendar
  }
  
  func make24hStrings() -> [String] {
    var numbers = [String]()
    numbers.append("00:00")

    for i in 1...24 {
      let i = i % 24
      var string = i < 10 ? "0" + String(i) : String(i)
      string.append(":00")
      numbers.append(string)
    }

    return numbers
  }

  func make12hStrings() -> [String] {
    var numbers = [String]()
    numbers.append("12")

    for i in 1...11 {
      let string = String(i)
      numbers.append(string)
    }

    var am = numbers.map { $0 + " " + calendar.amSymbol}
    var pm = numbers.map { $0 + " " + calendar.pmSymbol}
    
    am.append(localizedString("12:00"))
    pm.removeFirst()
    pm.append(am.first!)
    return am + pm
  }
}
