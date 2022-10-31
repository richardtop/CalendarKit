import Foundation

extension Date {
  func dateOnly(calendar: Calendar) -> Date {
    let yearComponent = calendar.component(.year, from: self)
    let monthComponent = calendar.component(.month, from: self)
    let dayComponent = calendar.component(.day, from: self)
    let zone = calendar.timeZone

    let newComponents = DateComponents(timeZone: zone,
                                       year: yearComponent,
                                       month: monthComponent,
                                       day: dayComponent)
    let returnValue = calendar.date(from: newComponents)
    return returnValue!
  }
    
    func currentYear() -> Int {
        return Calendar.current.component(.year, from: Date())
    }
    
    func year() -> Int {
        return  Calendar.current.component(.year, from: self)
    }
    
    func timeOnly() -> Float {
        let hour = Double(Calendar.current.component(.hour, from: Date()))
        let minute = Double(Calendar.current.component(.minute, from: Date()))
        var time = hour
        let minutesInPercent = minute / 60.0
        if minutesInPercent < 1 {
            time = hour + minutesInPercent
        }
        return Float(time)
    }
}
