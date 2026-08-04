import Foundation

public extension Date {
    struct ResultStruct {
        let year: Int?
        let month: Int?
        let week: Int?
        let day: Int?
        let hour: Int?
        let minute: Int?
        let second: Int?
    }
    
    init(_ dateString: String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        let date = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval: 0, since: date)
    }

    static func - (recent: Date, previous: Date) -> ResultStruct {
        let year = Calendar.current.dateComponents([.year], from: previous, to: recent).year
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let week = Calendar.current.dateComponents([.weekOfYear], from: previous, to: recent).weekOfYear
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second
        
        return ResultStruct(year: year, month: month, week: week, day: day, hour: hour, minute: minute, second: second)
    }

    var startOfSecond: Date { self.start(ofDateComponents: [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]) }
    var startOfHour: Date { self.start(ofDateComponents: [.year, .month, .weekOfMonth, .day, .hour]) }
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
    var startOfWeek: Date { self.start(ofDateComponents: [.yearForWeekOfYear, .weekOfYear]) }
    var startOfMonth: Date { self.start(ofDateComponents: [.year, .month]) }
    var startOfYear: Date { self.start(ofDateComponents: [.year]) }
    
    private func start(ofDateComponents dateComponents: Set<Calendar.Component>) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents(dateComponents, from: self)) ?? self
    }
}
