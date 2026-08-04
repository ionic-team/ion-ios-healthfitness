import Foundation
import HealthKit
import CloudKit

public struct VariableStruct {
    let allVariables: String
    let fitnessVariables: String
    let healthVariables: String
    let profileVariables: String
    let workoutVariables: String
    
    public init(allVariables: String, fitnessVariables: String, healthVariables: String, profileVariables: String, workoutVariables: String) {
        self.allVariables = allVariables
        self.fitnessVariables = fitnessVariables
        self.healthVariables = healthVariables
        self.profileVariables = profileVariables
        self.workoutVariables = workoutVariables
    }
}

open class HealthFitnessPlugin {
    
    let healthKitManager: HealthKitManager?
    
    public init() {
        let store = HKHealthStore()
        let backgroundManager = BackgroundJobManager()
        let notificiationManager = NotificationManager()
        self.healthKitManager = HealthKitManager(store: store, backgroundManager: backgroundManager, notificationManager: notificiationManager)
    }
    
    public func deleteBackgroundJobs(id: String?, completion: @escaping (NSError?) -> Void) {
        guard let stdId = id,
              let jobId = Int64(stdId),
              let jobs = self.healthKitManager?.getBackgroundJobs(id: jobId),
              let job = jobs.first,
              let variable = job.variable
        else {
            completion(HealthKitErrors.backgroundJobNotFound as NSError)
            return
        }
        
        guard let type = self.healthKitManager?.healthTypes.allVariablesDict[variable],
              let objectType = type.first?.objectType,
              let authStatus = self.healthKitManager?.store?.checkAuthorizationStatus(for: objectType),
              authStatus != .notDetermined
        else {
            completion(HealthKitErrors.variableNotAvailable as NSError)
            return
        }
        
        self.healthKitManager?.deleteBackgroundJobs(id: jobId) { error in
            if let error = error {
                completion(error)
            } else {
                if self.countBackgroundJobsFor(variable: variable) == 0 {
                    self.healthKitManager?.store?.disableBackgroundDeliveryFor(type: objectType) { result in
                        switch result {
                        case .failure:
                            completion(HealthKitErrors.unsubscribeError as NSError)
                        case .success:
                            completion(nil)
                        }
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }

    public func countBackgroundJobsFor(variable: String) -> Int {
        return self.healthKitManager?.countBackgroundJobsFor(variable: variable) ?? 0
    }
    
    public func listBackgroundJobs() -> String {
        return self.healthKitManager?.listBackgroundJobs()?.encode() ?? ""
    }
    
    public func writeData(variable: String, value: Double, completion: @escaping (Bool, NSError?) -> Void) {
        self.healthKitManager?.writeData(variable: variable, value: value) { inner in
            do {
                _ = try inner()
                completion(true, nil)
            } catch {
                completion(false, error as NSError)
            }
        }
    }
    
    public func getLastRecord(variable: String, mostRecent: Bool, timeUnitLength: Int, completion: @escaping (Bool, String?, NSError?) -> Void) {
        healthKitManager?.advancedQuery(
            variable: variable,
            startDate: Date.distantPast,
            endDate: Date(),
            timeUnit: "",
            operationType: "",
            mostRecent: mostRecent,
            timeUnitLength: timeUnitLength
        ) { result, error in
            if let error = error {
                completion(false, nil, error)
            } else if let result = result {
                completion(true, result.encode(), nil)
            }
        }
    }
    
    public func requestPermissions(customPermissions: String, variable: VariableStruct, completion: @escaping (Bool, NSError?) -> Void) {
        healthKitManager?.authorizeHealthKit(
            customPermissions: customPermissions,
            variable: variable
        ) { completion($0, $1) }
    }
    
    public func setBackgroundJob(
        variable: String,
        timeUnit: (name: String, grouping: Int),
        notificationFrequency: (name: String, grouping: Int),
        jobFrequency: String,
        condition: String,
        value: Double,
        notificationText: (header: String, body: String),
        completion: @escaping (Bool, String?, NSError?) -> Void
    ) {
        healthKitManager?.setBackgroundJob(
            variable: variable,
            timeUnit: timeUnit,
            notificationFrequency: notificationFrequency,
            jobFrequency: jobFrequency,
            condition: condition,
            value: value,
            notificationText: notificationText
        ) { result in
            switch result {
            case .success:
                completion(true, "", nil)
            case .failure(let error):
                completion(false, nil, error as NSError)
            }
        }
    }
    
    public func updateBackgroundJob(
        id: Int64?,
        notificationFrequency: (name: String?, grouping: Int?),
        condition: String?,
        value: Double?,
        notificationText: (header: String?, body: String?),
        isActive: Bool?,
        completion: @escaping (Bool, NSError?) -> Void
    ) {
        healthKitManager?.updateBackgroundJob(
            id: id,
            notificationFrequency: notificationFrequency,
            condition: condition,
            value: value,
            notificationText: notificationText,
            isActive: isActive
        ) { result in
            switch result {
            case .success:
                completion(true, nil)
            case .failure(let error):
                completion(false, error as NSError)
            }
        }
    }
    
    public func advancedQuery(
        variable: String,
        date: (start: Date, end: Date),
        timeUnit: String,
        operationType: String,
        mostRecent: Bool,
        onlyFilledBlocks: Bool,
        resultType: AdvancedQueryResultType = .allType,
        timeUnitLength: Int,
        completion: @escaping (Bool, String?, NSError?) -> Void
    ) {
        healthKitManager?.advancedQuery(
            variable: variable,
            startDate: date.start,
            endDate: date.end,
            timeUnit: timeUnit,
            operationType: operationType,
            mostRecent: mostRecent,
            onlyFilledBlocks: onlyFilledBlocks,
            resultType: resultType,
            timeUnitLength: timeUnitLength
        ) { result, error in
            if let error = error {
                completion(false, nil, error)
            } else if let result = result {
                completion(true, result.encode(), nil)
            }
        }
    }
    
    public func workoutAdvancedQuery(
        workoutTypeVariableDictionary: WorkoutTypeVariableDictionary,
        date: (start: Date, end: Date),
        completion: @escaping (Bool, String?, NSError?) -> Void
    ) {
        self.healthKitManager?.workoutAdvancedQuery(
            workoutTypeVariableDictionary: workoutTypeVariableDictionary,
            startDate: date.start,
            endDate: date.end
        ) { result, error in
            if let error = error {
                completion(false, nil, error)
            } else if let result = result {
                completion(true, result.encode(), nil)
            }
        }
    }
}
