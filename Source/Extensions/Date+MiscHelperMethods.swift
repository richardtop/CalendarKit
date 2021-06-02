import Foundation

extension Date {
    static var calendarToUse: Calendar = .autoupdatingCurrent
    var calendarToUse: Calendar = .autoupdatingCurrent

    func components(_ components: Set<Calendar.Component>) -> DateComponents {
        calendarToUse.dateComponents(components, from: self)
    }

    func component(_ component: Calendar.Component) -> Int {
        calendarToUse.component(component, from: self)
    }

    /// The current year (ex: 2020, 1995, etc)
    var year: Int { component(.year) }

    /// The month (ex: January = 1, etc)
    var month: Int { component(.month) }

    /// The day of the month (ex: 1, 12, 31, etc)
    var day: Int { component(.day) }
    
    /// The current day of the week (ex: Sunday = 1, Wednesday = 4, Saturday = 7, etc)
    var weekday: Int { component(.weekday) }

    /// The full name of the current day of the week (ex: "Sunday", "Wednesday", etc)
    var weekdayName: String {
        let dateFormatter = utcDateFormatter
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }

    /// The abbreviated name of the current day of the week (ex: "Sun", "Wed", etc)
    var weekdayNameAbbrv: String {
        let dateFormatter = utcDateFormatter
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self)
    }
    
    /// The full name of the current month (ex: "January", "May", etc)
    var monthName: String {
        let dateFormatter = utcDateFormatter
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: self)
    }

    /// The abbreviated name of the current month (ex: "Jan", "May", etc)
    var monthNameAbbrv: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self)
    }

    /// The number of days are in the current month (ex: 30, 31, 28,  etc)
    var daysInCurrentMonth: Int? {
        guard let date = calendarToUse.date(from: components([.year, .month])) else { return nil }
        guard let range = calendarToUse.range(of: .day, in: .month, for: date) else { return nil }

        return range.count
    }

    /// The first day of the month that the given date is in
    var firstDayOfMonth: Date? {
        let components = calendarToUse.dateComponents([.year, .month], from: self)
        return calendarToUse.date(from: components)
    }
    
    /// A full description of the date
    /// Example:
    /// "Today is Monday, May 31st, 2021"
    var fullDateName: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        let dayName: String = numberFormatter.string(from: NSNumber(value: day)) ?? String(day)
        return "Today is \(weekdayName), \(monthName) \(dayName), \(year)"
    }

    /// Compare two dates to see if they're the same on a given level (ie, month, year, etc)
    func compare(to comparisonDate: Date, by granularity: Calendar.Component = .day) -> Bool {
        calendarToUse.isDate(self, equalTo: comparisonDate, toGranularity: granularity)
    }

    /// Create a date by specifying a year, month, and day
    static func from(year: Int, month: Int, day: Int, hours: Int = 0, minutes: Int = 0) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hours
        dateComponents.minute = minutes
        dateComponents.timeZone = .autoupdatingCurrent

        return calendarToUse.date(from: dateComponents) ?? nil
    }
}
