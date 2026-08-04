import Foundation
@testable import IONHealthFitnessLib

class StubBackgroundJobManager: BackgroundJobManagerProtocol {
    
    var backgroundJobExists = false
    var backgroundJobs = [Int64: StubBackgroundJob]()
    var hasBackgroundJobs = false
    var unsubscribeError = false
    
    func fetchNotifications() -> [IONHealthFitnessLib.Notification] {
        return []
    }
    func fetchBackgroundJobs() -> [BackgroundJob] {
        
        var result: [BackgroundJob] = []
        if hasBackgroundJobs {
            
            let jobNotification = StubNotification(id: 1, title: "Test", body: "Test")
            let job = StubBackgroundJob(id: 1,
                                        variable: "HEART_RATE",
                                        comparison: "HIGHER",
                                        value: 10.0,
                                        isActive: true,
                                        notification: jobNotification,
                                        notificationFrequency: "DAY",
                                        notificationFrequencyGrouping: 1,
                                        lastNotificationTimestamp: Date(),
                                        timeUnit: "DAY",
                                        timeUnitGrouping: 1
            )
            backgroundJobs[job.id] = job

            for key in backgroundJobs.keys {
                result.append(backgroundJobs[key]!)
            }
        }
        return result
    }
    func fetchBackgroundJobBy(id: Int64) -> [BackgroundJob] {
        var result = [BackgroundJob]()
        
        if let backgroundJobID = backgroundJobs[id] {
            result += [backgroundJobID]
        }
        
        return result
    }
    
    func fetchBackgroundJobsFor(variable: String) -> [BackgroundJob] {
        return backgroundJobs.values.filter { $0.variable == variable }
    } 
    
    func deleteBackgroundJobs(id: Int64) throws {
        if !backgroundJobExists {
            throw HealthKitErrors.backgroundJobNotFound
        } else if unsubscribeError {
            throw HealthKitErrors.unsubscribeError
        }
        backgroundJobs.removeValue(forKey: id)
    }
    
    func insertOrUpdateNotification(notificationHeader: String, notificationBody: String) throws -> IONHealthFitnessLib.Notification? {
        return nil
    }
    
    func updateBackgroundJob(id: Int64, lastNotificationTimestamp: Date) throws {
        backgroundJobs[id]?.stubLastNotificationTimestamp = lastNotificationTimestamp
    }
    
    func updateBackgroundJobWithNotification(
        id: Int64,
        notificationFrequency: (name: String?, grouping: Int?),
        condition: String?,
        value: Double?,
        notificationText: (header: String?, body: String?),
        isActive: Bool?
    ) throws {
        if !backgroundJobExists {
            throw HealthKitErrors.backgroundJobNotFound
        }
    }
    
    func insertBackgroundJob(
        comparision: String,
        variable: String,
        notificationFrequency: (name: String, grouping: Int),
        timeUnit: (name: String, grouping: Int),
        operation: String,
        value: Double,
        notification: IONHealthFitnessLib.Notification
    ) throws {
        print("Nothing to do here.")
    }
    
    func insertBackgroundJobWithNotification(
        comparision: String,
        variable: String,
        notificationFrequency: (name: String, grouping: Int),
        timeUnit: (name: String, grouping: Int),
        operation: String,
        value: Double,
        notificationText: (header: String, body: String)
    ) throws {
        
        if backgroundJobExists {
            throw HealthKitErrors.backgroundJobAlreadyExists
        }
        
        let jobId = Int64(backgroundJobs.values.count)
        let notification = StubNotification(id: jobId, title: notificationText.header, body: notificationText.body)
        let job = StubBackgroundJob(id: jobId,
                                    variable: variable,
                                    comparison: comparision,
                                    value: value,
                                    isActive: true,
                                    notification: notification,
                                    notificationFrequency: notificationFrequency.name,
                                    notificationFrequencyGrouping: Int64(notificationFrequency.grouping),
                                    lastNotificationTimestamp: Date.init(timeIntervalSince1970: 0),
                                    timeUnit: timeUnit.name,
                                    timeUnitGrouping: Int64(timeUnit.grouping))
        backgroundJobs[jobId] = job
    }
    
    public func setBackgroundJobExists(_ value: Bool) {
        self.backgroundJobExists = value
    }
    
    public func setHasBackgroundJobs(_ value: Bool) {
        self.hasBackgroundJobs = value
    }

    public func setUnsubscribeError(_ value: Bool) {
        self.unsubscribeError = value
    }
}
