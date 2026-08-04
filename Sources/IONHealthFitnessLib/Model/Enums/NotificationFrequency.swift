import Foundation

class NotificationFrequency {
    
    enum Enum: String {
        case always = "ALWAYS",
             second = "SECOND",
             minute = "MINUTE",
             hour = "HOUR",
             day = "DAY",
             week = "WEEK",
             month = "MONTH",
             year = "YEAR"
    }
    
    static func get(notificationFrequency: String) -> Calendar.Component {
        var component: Calendar.Component
        switch notificationFrequency {
        case Enum.second.rawValue:
            component = .second
        case Enum.minute.rawValue:
            component = .minute
        case Enum.hour.rawValue:
            component = .hour
        case Enum.day.rawValue:
            component = .day
        case Enum.week.rawValue:
            component = .weekOfYear
        case Enum.month.rawValue:
            component = .month
        case Enum.year.rawValue:
            component = .year
        default:
            component = .day
        }
        return component
    }
}
