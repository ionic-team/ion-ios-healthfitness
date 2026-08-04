import Foundation
import CoreData

@objc
class BackgroundJobManager: NSObject {
    
    let constLastBackgroundJobID = "LastBackgroundJobID"
    let constLastNotificationID = "LastNotificationID"
    
    override init() {}
    
    private static var persistentContainer: NSPersistentContainer = {
        let momdName = "BackgroundModel"

        #if SWIFT_PACKAGE
        let customKitBundle = Bundle.module
        #else
        let customKitBundle = Bundle(for: BackgroundJobManager.self)
        #endif
        guard let modelURL = customKitBundle.url(forResource: momdName, withExtension: "momd") else {
            fatalError("Error initializing mom")
        }

        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        // let container = NSPersistentContainer(name: "BackgroundModel")
        let container = NSPersistentContainer(name: momdName, managedObjectModel: mom)
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return BackgroundJobManager.persistentContainer.viewContext
    }
    
    private func saveContext () throws {
        let context = BackgroundJobManager.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print(nserror.localizedDescription)
                throw nserror
            }
        }
    }
    
    private func saveLastBackgroundJobID(id: Int) {
        UserDefaults.standard.set(id, forKey: constLastBackgroundJobID)
    }
    
    private func getLastBackgroundJobID() -> Int {
        UserDefaults.standard.integer(forKey: constLastBackgroundJobID)
    }

    private func saveLastNotificationID(id: Int) {
        UserDefaults.standard.set(id, forKey: constLastNotificationID)
    }
    
    private func getLastNotificationID() -> Int {
        UserDefaults.standard.integer(forKey: constLastNotificationID)
    }
}

extension BackgroundJobManager: BackgroundJobManagerProtocol {
    // MARK: - fetch
    func fetchNotifications() -> [Notification] {
        let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
        var notifications = [Notification]()
        do {
            notifications = try self.context.fetch(fetchRequest)
        } catch {}
        
        return notifications
    }
    
    func fetchBackgroundJobs() -> [BackgroundJob] {
        let fetchRequest: NSFetchRequest<BackgroundJob> = BackgroundJob.fetchRequest()
        var backgroundJobs = [BackgroundJob]()
        do {
            backgroundJobs = try self.context.fetch(fetchRequest)
        } catch {}
        
        return backgroundJobs
    }
    
    func fetchBackgroundJobBy(id: Int64) -> [BackgroundJob] {
        var backgroundJobs = [BackgroundJob]()
        let fetchRequest: NSFetchRequest<BackgroundJob> = BackgroundJob.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %i", id)
        do {
            backgroundJobs = try self.context.fetch(fetchRequest)
        } catch {}
        return backgroundJobs
    }
    
    func fetchBackgroundJobsFor(variable: String) -> [BackgroundJob] {
        var backgroundJobs = [BackgroundJob]()
        let fetchRequest: NSFetchRequest<BackgroundJob> = BackgroundJob.fetchRequest()
        if !variable.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "variable == %@", variable)
        }
        do {
            backgroundJobs = try self.context.fetch(fetchRequest)
        } catch {}
        
        return backgroundJobs
    }
    
    func deleteBackgroundJobs(id: Int64) throws {
        
        let fetchRequest: NSFetchRequest<BackgroundJob> = BackgroundJob.fetchRequest()
        let predicate = NSPredicate(format: "id == %i", id)
        fetchRequest.predicate = predicate
        
        let fetchRequestResults = try self.context.fetch(fetchRequest)
        if let result = fetchRequestResults.first {
            self.context.delete(result)
            
            do {
                try self.saveContext()
            } catch {
                throw HealthKitErrors.unsubscribeError
            }
        }
    }
    
    func insertOrUpdateNotification(notificationHeader: String,
                                    notificationBody: String) throws -> Notification? {
        var notificationToReturn: Notification?
        let predicate = NSPredicate(format: "title == %@ AND body == %@", notificationHeader, notificationBody)
        let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
        fetchRequest.predicate = predicate
        
        let fetchRequestResults = try self.context.fetch(fetchRequest)
        if let notification = fetchRequestResults.first {
            notificationToReturn = notification
        } else {
            let notification = Notification(context: self.context)
            notification.title = notificationHeader
            notification.body = notificationBody
            let lastID = Int64(getLastNotificationID())
            notification.id = lastID + 1
            notificationToReturn = notification
            
            try self.saveContext()
            saveLastNotificationID(id: Int(notification.id))
        }
        
        return notificationToReturn
    }
    
    func updateBackgroundJob(id: Int64, lastNotificationTimestamp: Date) throws {
        let predicate = NSPredicate(format: "id == %i", id)
        let fetchRequest = BackgroundJob.fetchRequest()
        fetchRequest.predicate = predicate
        
        let fetchRequestResults = try self.context.fetch(fetchRequest)        
        if let result = fetchRequestResults.first {
            debugPrint("will save ", lastNotificationTimestamp)
            result.lastNotificationTimestamp = lastNotificationTimestamp
            
            try self.saveContext()
        }
    }
    
    func updateBackgroundJobWithNotification(
        id: Int64,
        notificationFrequency: (name: String?, grouping: Int?),
        condition: String?,
        value: Double?,
        notificationText: (header: String?, body: String?),
        isActive: Bool?
    ) throws {
        let jobPredicate = NSPredicate(format: "id == %i", id)
        let jobFetchRequest: NSFetchRequest<BackgroundJob> = BackgroundJob.fetchRequest()
        jobFetchRequest.predicate = jobPredicate
        
        let fetchRequestResults = try self.context.fetch(jobFetchRequest)
        guard let job = fetchRequestResults.first else { return }
        
        if let notificationFrequency = notificationFrequency.name {
            job.notificationFrequency = notificationFrequency
            job.lastNotificationTimestamp = Date(timeIntervalSince1970: 0)
        }
        
        if let notificationFrequencyGrouping = notificationFrequency.grouping {
            job.notificationFrequencyGrouping = Int64(notificationFrequencyGrouping)
            job.lastNotificationTimestamp = Date(timeIntervalSince1970: 0)
        }
        
        if condition != nil {
            job.comparision = condition
        }
        
        if let value = value {
            job.value = value
        }
        if let isActive = isActive {
            job.isActive = isActive
        }
        
        if let notification = job.notification {
            if let notificationHeader = notificationText.header {
                notification.title = notificationHeader
            }
            if let notificationBody = notificationText.body {
                notification.body = notificationBody
            }
        }
        
        try self.saveContext()
    }
    
    func insertBackgroundJob(
        comparision: String,
        variable: String,
        notificationFrequency: (name: String, grouping: Int),
        timeUnit: (name: String, grouping: Int),
        operation: String,
        value: Double,
        notification: Notification
    ) throws {
        let predicate = NSPredicate(format: "variable == %@ AND comparision == %@ AND value == %f", variable, comparision, value)
        let fetchRequest = BackgroundJob.fetchRequest()
        fetchRequest.predicate = predicate
        
        let fetchRequestResults = try self.context.fetch(fetchRequest)
        if !fetchRequestResults.isEmpty {
            throw HealthKitErrors.backgroundJobAlreadyExists
        } else {
            let backgroundJob = BackgroundJob(context: self.context)
            backgroundJob.comparision = comparision
            backgroundJob.variable = variable
            backgroundJob.operation = operation
            backgroundJob.value = value
            backgroundJob.timeUnit = timeUnit.name
            backgroundJob.isActive = true
            
            let notificationFrequencySolved = NotificationFrequency.get(notificationFrequency: notificationFrequency.name)
            backgroundJob.notificationFrequency = notificationFrequency.name
            backgroundJob.notificationFrequencyGrouping = Int64(notificationFrequency.grouping)
            
            let lastNotificationDate = Calendar.current.date(
                byAdding: notificationFrequencySolved,
                value: notificationFrequency.grouping * -1,
                to: Date()
            )!
            backgroundJob.lastNotificationTimestamp = lastNotificationDate
            backgroundJob.timeUnitGrouping = Int64(timeUnit.grouping)
            backgroundJob.notification = notification
            
            let lastID = getLastBackgroundJobID() + 1
            backgroundJob.id = Int64(lastID)
            
            try self.saveContext()
            saveLastBackgroundJobID(id: lastID)
        }
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
        let nofitication = try self.insertOrUpdateNotification(notificationHeader: notificationText.header,
                                                               notificationBody: notificationText.body)
        
        if let nofitication = nofitication {
            try self.insertBackgroundJob(comparision: comparision,
                                         variable: variable,
                                         notificationFrequency: notificationFrequency,
                                         timeUnit: timeUnit,
                                         operation: operation,
                                         value: value,
                                         notification: nofitication)
        }
    }
}
