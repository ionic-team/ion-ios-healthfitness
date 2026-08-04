import Foundation

public class BackgroundJobParameters: Codable {
    public let id: Int64?
    public let variable: String?
    public let timeUnit: String?
    public let timeUnitGrouping: Int?
    public let notificationFrequency: String?
    public let notificationFrequencyGrouping: Int?
    public let jobFrequency: String?
    public let condition: String?
    public let value: Double?
    public let notificationHeader: String?
    public let notificationBody: String?
    public let isActive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case variable = "Variable"
        case timeUnit = "TimeUnit"
        case timeUnitGrouping = "TimeUnitGrouping"
        case notificationFrequency = "NotificationFrequency"
        case notificationFrequencyGrouping = "NotificationFrequencyGrouping"
        case jobFrequency = "JobFrequency"
        case condition = "Condition"
        case value = "Value"
        case notificationHeader = "NotificationHeader"
        case notificationBody = "NotificationBody"
        case isActive = "IsActive"
    }
    
    public init(
        id: Int64?,
        variable: String?,
        timeUnit: String?,
        timeUnitGrouping: Int?,
        notificationFrequency: String?,
        notificationFrequencyGrouping: Int?,
        jobFrequency: String?,
        condition: String?,
        value: Double?,
        notificationHeader: String?,
        notificationBody: String?,
        isActive: Bool?
    ) {
        self.id = id
        self.variable = variable
        self.timeUnit = timeUnit
        self.timeUnitGrouping = timeUnitGrouping
        self.notificationFrequency = notificationFrequency
        self.notificationFrequencyGrouping = notificationFrequencyGrouping
        self.jobFrequency = jobFrequency
        self.condition = condition
        self.value = value
        self.notificationHeader = notificationHeader
        self.notificationBody = notificationBody
        self.isActive = isActive
    }
}
