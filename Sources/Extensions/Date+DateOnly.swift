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
    
    /* Returns current time in Float
     - before point - hours
     - after point  - percent of minutes in hour
     */
    func timeOnly() -> Float {
        let hours = Double(Calendar.current.component(.hour, from: Date()))
        let minutes = Double(Calendar.current.component(.minute, from: Date()))
        var time = hours
        let minutesInPercent = minutes / 60.0
        if minutesInPercent < 1 {
            time = hours + minutesInPercent
        }
        return Float(time)
    }
}
