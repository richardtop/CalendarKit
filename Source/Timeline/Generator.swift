import Foundation

enum Generator {
  static func timeStrings24H() -> [String] {
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

  static func timeStrings12H() -> [String] {
    var numbers = [String]()
    numbers.append("12")

    for i in 1...11 {
      let string = String(i)
      numbers.append(string)
    }

    var am = numbers.map { $0 + " AM" }
    var pm = numbers.map { $0 + " PM" }
    am.append("Noon")
    pm.removeFirst()
    pm.append(am.first!)
    return am + pm
  }
}
