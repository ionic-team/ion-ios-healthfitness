import Foundation

protocol BackgroundJobManagerProtocol {
    
    func fetchNotifications() -> [Notification]
    func fetchBackgroundJobs() -> [BackgroundJob]
    func fetchBackgroundJobBy(id: Int64) -> [BackgroundJob]
    func fetchBackgroundJobsFor(variable: String) -> [BackgroundJob]
    func deleteBackgroundJobs(id: Int64) throws
    func insertOrUpdateNotification(notificationHeader: String, notificationBody: String) throws -> Notification?
    func updateBackgroundJob(id: Int64, lastNotificationTimestamp: Date) throws
    func updateBackgroundJobWithNotification(
        id: Int64,
        notificationFrequency: (name: String?, grouping: Int?),
        condition: String?,
        value: Double?,
        notificationText: (header: String?, body: String?),
        isActive: Bool?
    ) throws
    func insertBackgroundJob(
        comparision: String,
        variable: String,
        notificationFrequency: (name: String, grouping: Int),
        timeUnit: (name: String, grouping: Int),
        operation: String,
        value: Double,
        notification: Notification
    ) throws
    func insertBackgroundJobWithNotification(
        comparision: String,
        variable: String,
        notificationFrequency: (name: String, grouping: Int),
        timeUnit: (name: String, grouping: Int),
        operation: String,
        value: Double,
        notificationText: (header: String, body: String)
    ) throws
}
