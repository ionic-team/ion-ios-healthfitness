import HealthKit
import UserNotifications

class HealthKitManager: NSObject {
    var store: HealthKitManagerProtocol?
    var backgroundManager: BackgroundJobManagerProtocol?
    var notificationManager: NotificationManagerProtocol?
    var healthKitTypesToRead = Set<HKObjectType>()
    var healthKitTypesToWrite = Set<HKSampleType>()
    var healthTypes = HealthKitTypes()
    
    init(store: HealthKitManagerProtocol, backgroundManager: BackgroundJobManagerProtocol, notificationManager: NotificationManagerProtocol) {
        super.init()
        self.store = store
        self.backgroundManager = backgroundManager
        self.notificationManager = notificationManager
        notificationManager.setDelegate(delegate: self)
    
        DispatchQueue.main.async {
            self.verifyBackgroundJobs(variable: "")
        }
    }
    
    func deleteBackgroundJobs(id: Int64?, completion: @escaping (NSError?) -> Void) {
        var error: NSError?
        
        do {
            if let jobId = id {
                try self.backgroundManager?.deleteBackgroundJobs(id: jobId)
            } else {
                throw HealthKitErrors.backgroundJobNotFound
            }
        } catch let err as NSError {
            error = err
        }
        
        completion(error)
    }
    
    func listBackgroundJobs() -> BackgroundJobsResponse? {
        guard let jobs = self.backgroundManager?.fetchBackgroundJobs() else { return nil }
        let backgroundJobsResultsArray = jobs.map {
            BackgroundJobsResponseBlock(
                variable: $0.variable,
                condition: $0.comparision,
                value: $0.value,
                notificationHeader: $0.notification?.title,
                notificationBody: $0.notification?.body,
                notificationFrequency: $0.notificationFrequency,
                notificationFrequencyGrouping: Int($0.notificationFrequencyGrouping),
                active: String($0.isActive),
                id: String($0.id)
            )
        }
        
        return BackgroundJobsResponse(results: backgroundJobsResultsArray)
    }
    
    func getBackgroundJobs(id: Int64) -> [BackgroundJob]? {
        return self.backgroundManager?.fetchBackgroundJobBy(id: id)
    }
    
    func countBackgroundJobsFor(variable: String) -> Int {
        return self.backgroundManager?.fetchBackgroundJobsFor(variable: variable).count ?? 0
    }
        
    func verifyBackgroundJobs(variable: String) {
        guard let jobs = self.backgroundManager?.fetchBackgroundJobsFor(variable: variable) else { return }
        
        for item in jobs {
            let backgroundJobID = item.id
            guard
                let variable = item.variable,
                let timeUnit = item.timeUnit,
                let notificationID = item.notification?.id
            else { return }

            let dateComponent = self.getInterval(timeUnit: timeUnit, timeUnitLength: 0)
            
            guard
                let startDate = Calendar.current.date(byAdding: dateComponent, to: Date()),
                let type = self.healthTypes.allVariablesDict[variable],
                let sampleType = type.first?.sampleType,
                let operations = type.first?.optionsAllowed,
                let objectType = type.first?.objectType,
                self.store?.checkAuthorizationStatus(for: objectType) != .notDetermined
            else { return }
            
            self.store?.executeObserverQuery(sampleType: sampleType, predicate: nil, updateHandler: { [weak self] _, completionHandler, _ in
                guard let self = self,
                      let backgroundUpdated = self.backgroundManager?.fetchBackgroundJobBy(id: backgroundJobID).first,
                      let lastNotify = backgroundUpdated.lastNotificationTimestamp,
                      let notificationFrequency = backgroundUpdated.notificationFrequency,
                      let comparison = backgroundUpdated.comparision,
                      let notificationHeader = backgroundUpdated.notification?.title,
                      let notificationBody = backgroundUpdated.notification?.body
                else { return }
                
                let notificationFrequencySolved = NotificationFrequency.get(notificationFrequency: notificationFrequency)
                guard let interval = self.getTimeIntervalResult(
                    notificationFrequency: notificationFrequencySolved,
                    lastNotificationTimestamp: lastNotify
                ) else { return }
                
                var firstDateOfTimePeriod = startDate.startOfSecond
                if let timeUnit = TimeUnitEnum(rawValue: notificationFrequency) {
                    switch timeUnit {
                    case .hour: firstDateOfTimePeriod = startDate.startOfHour
                    case .day: firstDateOfTimePeriod = startDate.startOfDay
                    case .week: firstDateOfTimePeriod = startDate.startOfWeek
                    case .month: firstDateOfTimePeriod = startDate.startOfMonth
                    case .year: firstDateOfTimePeriod = startDate.startOfYear
                    default: break
                    }
                }
                
                if backgroundUpdated.isActive &&
                    (interval >= backgroundUpdated.notificationFrequencyGrouping ||
                     notificationFrequency == NotificationFrequency.Enum.always.rawValue) {
                    self.runAnchoredQuery(
                        sampleType: sampleType,
                        variable: variable,
                        date: (firstDateOfTimePeriod, Date()),
                        timeUnit: timeUnit,
                        operations: operations,
                        mostRecent: false,
                        comparision: comparison,
                        notificationID: String(notificationID),
                        notificationText: (notificationHeader, notificationBody),
                        triggerValue: backgroundUpdated.value,
                        backgroundJobID: backgroundJobID
                    ) { _ in
                        completionHandler()
                    }
                } else {
                    completionHandler()
                }
            })
        }
    }
    
    func parseCustomPermissons(customPermissions: String) -> Bool {
        var result = true
        
        if let permissions = customPermissions.decode() as PermissionsArray? {
            permissions.forEach { element in
                if let type = healthTypes.allVariablesDict[element.variable] {
                    type.forEach { item in
                        self.fillSets(accessType: element.variable, sampleType: item.sampleType, objectType: item.objectType)
                    }
                } else {
                    result = false
                    return
                }
            }
        }
        
        return result
    }
    
    func authorizeHealthKit(customPermissions: String, variable: VariableStruct, completion: @escaping (Bool, NSError?) -> Void) {
        if let error = isHealthDataAvailable() {
            return completion(false, error)
        }
        
        self.fillSetsWithHistory()
        
        if !variable.allVariables.isEmpty, let all = variable.allVariables.decode() as GroupPermissions?, all.isActive {
            self.fillPermissionSetWithVariables(dict: healthTypes.allVariablesDict, groupPermissions: all)
        }

        if !variable.fitnessVariables.isEmpty, let fitness = variable.fitnessVariables.decode() as GroupPermissions?, fitness.isActive {
            self.fillPermissionSetWithVariables(dict: healthTypes.fitnessVariablesDict, groupPermissions: fitness)
        }

        if !variable.healthVariables.isEmpty, let health = variable.healthVariables.decode() as GroupPermissions?, health.isActive {
            self.fillPermissionSetWithVariables(dict: healthTypes.healthVariablesDict, groupPermissions: health)
        }
        
        if !variable.profileVariables.isEmpty, let profile = variable.profileVariables.decode() as GroupPermissions?, profile.isActive {
            self.fillPermissionSetWithVariables(dict: healthTypes.profileVariablesDict, groupPermissions: profile)
        }
        
        if !variable.workoutVariables.isEmpty, let workout = variable.workoutVariables.decode() as GroupPermissions?, workout.isActive {
            self.fillPermissionSetWithVariables(dict: healthTypes.workoutVariablesDict, groupPermissions: workout)
        }

        if !customPermissions.isEmpty, !self.parseCustomPermissons(customPermissions: customPermissions) {
            return completion(false, HealthKitErrors.variableNotAvailable as NSError)
        }

        self.store?.requestAuthorization(
            setToWrite: self.healthKitTypesToWrite, setToRead: self.healthKitTypesToRead
        ) { [weak self] success, error in
            guard let self = self else { return }
            
            self.healthKitTypesToWrite.removeAll()
            self.healthKitTypesToRead.removeAll()
            
            completion(success, error)
        }
    }
    
    func writeData(variable: String, value: Double?, completion: @escaping (_ inner: @escaping () throws -> HealthKitErrors?) -> Void) {
        if let error = self.isHealthDataAvailable() {
            return completion({ throw error })
        }
        
        guard let type = self.healthTypes.allVariablesDict[variable],
              let unit = type.first?.unit,
              let quantityType = type.first?.quantityType
        else { return completion({ throw HealthKitErrors.variableNotAvailable }) }
        
        if let objectType = type.first?.objectType,
           let authStatus = self.store?.checkAuthorizationStatus(for: objectType),
           authStatus == .sharingDenied {
            return completion({ throw HealthKitErrors.variableHasWriteDenied })
        }

        if var val = value {
            if unit == .percent() { val /= 100 }
            let countSample = HKQuantitySample(
                type: quantityType,
                quantity: HKQuantity(unit: unit, doubleValue: val),
                start: Date(),
                end: Date(),
                metadata: [HKMetadataKeyWasUserEntered : true]
            )
            
            self.store?.writeData(sample: countSample) { inner in
                do {
                    _ = try inner()
                    completion({ nil })
                } catch let error as NSError {
                    switch error.code {
                    case 1:
                        completion({ throw HealthKitErrors.notAvailableOnDevice })
                    case 5:
                        completion({ throw HealthKitErrors.authorizationError })
                    default:
                        completion({ throw error })
                    }
                }
            }
        }
    }

    func advancedQuery(
        variable: String,
        startDate: Date,
        endDate: Date,
        timeUnit: String,
        operationType: String,
        mostRecent: Bool,
        onlyFilledBlocks: Bool = false,
        resultType: AdvancedQueryResultType = .allType,
        timeUnitLength: Int,
        completion: @escaping (AdvancedQueryResponse?, NSError?) -> Void
    ) {
        if let error = self.isHealthDataAvailable() {
            return completion(nil, error)
        }
        
        guard let type = self.healthTypes.allVariablesDict[variable], let unit = type.first?.unit
        else { return completion(nil, HealthKitErrors.variableNotAvailable as NSError) }
    
        if let objectType = type.first?.objectType,
            let authStatus = self.store?.checkAuthorizationStatus(for: objectType),
            authStatus == .notDetermined {
            return completion(nil, HealthKitErrors.variableNotAuthorized as NSError)
        }
        
        // RAW bypasses statistics + options validation
        if OperationTypeEnum.raw.rawValue == operationType{
            executeRawQuery(types: type, startDate: startDate, endDate: endDate, timeUnit: timeUnit, timeUnitLength: timeUnitLength, unit: unit, resultType: resultType) { result in
                switch result {
                case .success(let response):
                    completion(response, nil)
                case .failure(let error):
                    completion(nil, error as NSError)
                }
            }
            return
        }
        
        let anchorDate = Calendar.current.date(from: self.getCalendarComponent(date: startDate))!
        let operations = self.getStatisticOptions(operationType: operationType)
        
        if operationType != OperationTypeEnum.mostRecent.rawValue {
            guard let optionsAllowed = type.first?.optionsAllowed else {
                return completion(nil, HealthKitErrors.operationNotAllowed as NSError)
            }

            if !optionsAllowed.contains(operations) {
                return completion(nil, HealthKitErrors.operationNotAllowed as NSError)
            }
        }
        
        // Intercept MIN / MAX to return record-level metadata
        let isMinMax = operationType == OperationTypeEnum.min.rawValue || operationType == OperationTypeEnum.max.rawValue
        let isSupportedTypeForMinMax = type.first?.quantityType != nil || type.first?.categoryType != nil
  
        if isMinMax && isSupportedTypeForMinMax {
            self.executeMinMaxWithMetadata(types: type, startDate: startDate, endDate: endDate,
                                           timeUnit: timeUnit, timeUnitLength: timeUnitLength, unit: unit, operationType: operationType, resultType: resultType) { result in
                switch result {
                case .success(let response):
                    completion(response, nil)
                case .failure(let error):
                    completion(nil, error as NSError)
                }
            }
            return
        }
        
        if let categoryType = type.first?.categoryType {
            self.executeSimpleQuery(
                forStartDate: startDate,
                endDate: endDate,
                sample: categoryType,
                operationType: operationType,
                sortDescriptorArray: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { [weak self] data in
                guard let self = self else { return }
                
                if let dataList = data {
                    let result = self.processCategoryTypeQueryResult(result: dataList as? [HKCategorySample] ?? [], andType: resultType, operationType: operationType)
                    completion(result, nil)
                } else {
                    completion(nil, HealthKitErrors.errorWhileReading as NSError)
                }
            }
        } else if let correlationType = type.first?.correlationType {
            self.executeSimpleQuery(
                forStartDate: startDate,
                endDate: endDate,
                sample: correlationType,
                operationType: operationType,
                sortDescriptorArray: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { [weak self] data in
                guard let self = self else { return }
                
                if let firstType = type[0].quantityType, let secondType = type[1].quantityType, let dataList = data as? [HKCorrelation] {
                    let result = self.processCorrelationQueryResult(
                        result: dataList, andType: resultType, firstType: firstType, secondType: secondType, operationType: operationType
                    )
                    completion(result, nil)
                } else {
                    completion(nil, HealthKitErrors.errorWhileReading as NSError)
                }
            }
        } else if let quantityType = type.first?.quantityType {
            
            if operationType == OperationTypeEnum.mostRecent.rawValue {
                self.executeSimpleQuery(
                    forStartDate: startDate,
                    endDate: endDate,
                    sample: quantityType,
                    operationType: operationType,
                    sortDescriptorArray: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
                ) { data in
                    guard let sample = data?.first as? HKQuantitySample else {
                        completion(AdvancedQueryResponse(results: nil, resultDataPoints: nil), nil)
                        return
                    }
                    
                    let rawValue = sample.quantity.doubleValue(for: unit)
                    let value = self.convertToUnit(rawValue, unit: unit)
                    
                    let block = AdvancedQueryResponseBlock(
                        block: 0,
                        startDate: Int(sample.startDate.timeIntervalSince1970),
                        endDate: Int(sample.endDate.timeIntervalSince1970),
                        values: [value],
                        recordMetadataList: [sample.healthRecordMetadata()]
                    )
                    
                    completion(AdvancedQueryResponse(results: [block], resultDataPoints: nil), nil)
                }
                
                return
            }
            
            var interval = self.getInterval(timeUnit: timeUnit, timeUnitLength: timeUnitLength)
            if OperationTypeEnum.mostRecent.rawValue == operationType {
                interval.year = (endDate - startDate).year
            }
            
            self.store?.executeAdvancedQuery(
                quantityType: quantityType,
                options: operations,
                anchorDate: anchorDate,
                interval: interval,
                date: (startDate, endDate),
                mostRecent: mostRecent,
                onlyFilledBlocks: onlyFilledBlocks,
                resultType: resultType,
                unit: unit
            ) { results in
                switch results {
                case .failure:
                    completion(nil, HealthKitErrors.errorWhileReading as NSError)
                case .success(let data):
                    completion(data, nil)
                }
            }
        }
    }
    
    func workoutAdvancedQuery(
        workoutTypeVariableDictionary: WorkoutTypeVariableDictionary,
        startDate: Date,
        endDate: Date,
        completion: @escaping (WorkoutAdvancedQueryResponse?, NSError?) -> Void
    ) {
        if let error = self.isHealthDataAvailable() {
            return completion(nil, error)
        }
        
        guard let workoutVariable = self.healthTypes.allVariablesDict[HealthTypeEnum.workout.rawValue]
        else { return completion(nil, HealthKitErrors.workoutTypeNotAvailable as NSError) }
        
        if let objectType = workoutVariable.first?.objectType,
            let authStatus = self.store?.checkAuthorizationStatus(for: objectType),
            authStatus == .notDetermined {
            return completion(nil, HealthKitErrors.workoutTypeNotAuthorized as NSError)
        }
        
        var workoutActivityTypeArray: [HKWorkoutActivityType]?
        let types = workoutTypeVariableDictionary
            .reduce((workout: WorkoutType(), variable: VariableType())) { ($0.workout.union($1.key), $0.variable.union($1.value)) }
        if types.workout != .all {
            workoutActivityTypeArray = self.healthTypes.workoutActivityTypesDict
                .filter({ types.workout.workoutTypeEnums().map { $0.rawValue }.contains($0.key) })
                .values
                .compactMap({ $0 })
            
            guard workoutActivityTypeArray?.isEmpty == false else { return completion(nil, HealthKitErrors.workoutTypeNotAvailable as NSError) }
        }
        
        types.variable.healthTypes().forEach { healthType in
            guard let variable = self.healthTypes.workoutVariablesDict[healthType.rawValue]
            else { return completion(nil, HealthKitErrors.variableNotAvailable as NSError) }
            
            if let objectType = variable.first?.objectType,
                let authStatus = self.store?.checkAuthorizationStatus(for: objectType),
                authStatus == .notDetermined {
                return completion(nil, HealthKitErrors.variableNotAuthorized as NSError)
            }
        }
    
        if let workoutType = workoutVariable.first?.workoutType {
            let sortDescriptorArray = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            
            self.executeWorkoutQuery(
                for: workoutType, with: workoutActivityTypeArray, startDate, endDate, and: sortDescriptorArray
            ) { [weak self] data in
                guard let self = self else { return }
                
                if let workoutArray = data {
                    self.processResults(for: workoutArray as? [HKWorkout] ?? [], with: workoutTypeVariableDictionary) { completion($0, nil) }
                } else {
                    completion(nil, HealthKitErrors.errorWhileReading as NSError)
                }
            }
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        self.notificationManager?.requestAuthorization(completion: completion)
    }
    
    func getFrequency(jobFrequency: String) -> HKUpdateFrequency {
        switch jobFrequency {
        case "IMMEDIATE":
            return .immediate
        case "DAY":
            return .daily
        case "WEEK":
            return .weekly
        default:
            return .hourly
        }
    }
    
    func setAnchorFor(anchor: HKQueryAnchor, variable: String) {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor as Any, requiringSecureCoding: false) else { return }
        UserDefaults.standard.set(data, forKey: "Anchor\(variable)")
    }

    func getAnchorFor(variable: String) -> HKQueryAnchor? {
        guard let data = UserDefaults.standard.object(forKey: "Anchor\(variable)") as? Data else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
    }
    
    func runAnchoredQuery(
        sampleType: HKSampleType,
        variable: String,
        date: (start: Date, end: Date),
        timeUnit: String,
        operations: [HKStatisticsOptions]?,
        mostRecent: Bool,
        comparision: String,
        notificationID: String,
        notificationText: (header: String, body: String),
        triggerValue: Double,
        backgroundJobID: Int64,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let anchor = self.getAnchorFor(variable: variable) ?? HKQueryAnchor(fromValue: 0)
        
        self.store?.executeAnchoredObjectQuery(
            type: sampleType,
            predicate: nil,
            anchor: anchor,
            limit: HKObjectQueryNoLimit,
            resultsHandler: { [weak self] _, _, _, newAnchor, _, hasChanges in
                guard let self = self else { return }
                
                if hasChanges {
                    guard let operations = operations else { return }
                    let option = operations.contains(.cumulativeSum) ? "SUM" : "AVERAGE"
                    
                    self.performQuery(
                        variable: variable,
                        date: date,
                        timeUnit: timeUnit,
                        operationType: option,
                        mostRecent: mostRecent,
                        comparision: comparision,
                        notificationID: notificationID,
                        notificationText: notificationText,
                        triggerValue: triggerValue,
                        backgroundJobID: backgroundJobID,
                        completion: completion
                    )
                }
                
                if let newAnchor = newAnchor {
                    self.setAnchorFor(anchor: newAnchor, variable: variable)
                }
            }
        )
    }
    
    func setBackgroundJob(
        variable: String,
        timeUnit: (name: String, grouping: Int),
        notificationFrequency: (name: String, grouping: Int),
        jobFrequency: String,
        condition: String,
        value: Double,
        notificationText: (header: String, body: String),
        completion: @escaping (Result<Bool?, Error>) -> Void
    ) {
        self.requestAuthorization { _ in }
        
        if let error = self.isHealthDataAvailable() {
            return completion(.failure(error))
        }
        
        guard let type = self.healthTypes.allVariablesDict[variable]
        else { return completion(.failure(HealthKitErrors.variableNotAvailable as NSError)) }
        
        guard let objectType = type.first?.objectType else { return }
        if self.store?.checkAuthorizationStatus(for: objectType) == .notDetermined {
            return completion(.failure(HealthKitErrors.variableNotAuthorized as NSError))
        }
        
        guard let operations = type.first?.optionsAllowed else { return }
        let operation = operations.contains(.cumulativeSum) ? "SUM" : "AVERAGE"
        let frequency = self.getFrequency(jobFrequency: jobFrequency)
                
        self.store?.enableBackgroundDelivery(for: objectType, andFrequency: frequency) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                do {
                    try self.backgroundManager?.insertBackgroundJobWithNotification(
                        comparision: condition,
                        variable: variable,
                        notificationFrequency: notificationFrequency,
                        timeUnit: timeUnit,
                        operation: operation,
                        value: value,
                        notificationText: notificationText
                    )
                    self.verifyBackgroundJobs(variable: variable)
                    
                    completion(.success(true))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateBackgroundJob(
        id: Int64?,
        notificationFrequency: (name: String?, grouping: Int?),
        condition: String?,
        value: Double?,
        notificationText: (header: String?, body: String?),
        isActive: Bool?,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard let jobId = id else { return completion(.failure(HealthKitErrors.backgroundJobNotFound as NSError)) }
        
        do {
            try self.backgroundManager?.updateBackgroundJobWithNotification(
                id: jobId,
                notificationFrequency: notificationFrequency,
                condition: condition,
                value: value,
                notificationText: notificationText,
                isActive: isActive
            )
            completion(.success(true))
        } catch {
            completion(.failure(error))
        }
    }
}

extension HealthKitManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func scheduleNotification(header: String, body: String, andId id: String) {
        let content = UNMutableNotificationContent()
        let actions = "Actions"
        
        content.title = header
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = actions
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = id
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        self.notificationManager?.addRequest(request: request) { _ in }
        
        let okAction = UNNotificationAction(identifier: "Ok", title: "Ok")
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: actions, actions: [okAction, deleteAction], intentIdentifiers: [])
        
        self.notificationManager?.setNotificationCategories(categories: [category])
    }
}

private extension HealthKitManager {
    func getTimeIntervalResult(notificationFrequency: Calendar.Component, lastNotificationTimestamp: Date) -> Int? {
        var timeInterval: Int?
        
        let delta = Date() - lastNotificationTimestamp
        switch notificationFrequency {
        case .second:
            timeInterval = delta.second
        case .minute:
            timeInterval = delta.minute
        case .hour:
            timeInterval = delta.hour
        case .weekOfYear:
            timeInterval = delta.week
        case .month:
            timeInterval = delta.month
        case .year:
            timeInterval = delta.year
        default:
            timeInterval = delta.day
        }
        
        return timeInterval
    }
    
    func fillSets(accessType: String, sampleType: HKSampleType, objectType: HKObjectType) {
        let accessTypeOptionSet = AccessType.getAccessType(for: accessType)
        if accessTypeOptionSet.contains(.read) {
            self.healthKitTypesToRead.insert(objectType)
        }
        if accessTypeOptionSet.contains(.write) {
            self.healthKitTypesToWrite.insert(sampleType)
        }
    }
    
    func fillPermissionSetWithVariables(dict: [String: [HealthKitVariable]], groupPermissions: GroupPermissions) {
        dict.forEach {
            $0.value.forEach {
                self.fillSets(accessType: groupPermissions.accessType, sampleType: $0.sampleType, objectType: $0.objectType)
            }
        }
    }
    
    func setPermissionsFor(variable: HealthKitVariable) {
        if let authStatus = self.store?.checkAuthorizationStatus(for: variable.objectType), authStatus == .sharingAuthorized {
            healthKitTypesToWrite.insert(variable.sampleType)
        }
        
        if let authStatusRead = self.store?.checkAuthorizationStatus(for: variable.objectType), authStatusRead != .notDetermined {
            healthKitTypesToRead.insert(variable.objectType)
        }
    }
    
    func fillSetsWithHistory() {
        self.healthTypes.allVariablesDict.values.forEach {
            $0.forEach {
                setPermissionsFor(variable: $0)
            }
        }
    }
    
    func isHealthDataAvailable() -> NSError? {
        !HKHealthStore.isHealthDataAvailable() ? HealthKitErrors.notAvailableOnDevice as NSError : nil
    }
    
    func getCalendarComponent(date: Date) -> DateComponents {
        return NSCalendar.current.dateComponents([.second, .minute, .hour, .day, .weekOfYear, .month, .year], from: date)
    }
    
    func getStatisticOptions(operationType: String) -> HKStatisticsOptions {
        var result = HKStatisticsOptions()
        
        if let operationTypeEnum = OperationTypeEnum(rawValue: operationType) {
            switch operationTypeEnum {
            case .sum:
                result = .cumulativeSum
            case .min:
                result = .discreteMin
            case .max:
                result = .discreteMax
            case .average:
                result = .discreteAverage
            case .mostRecent:
                result = .mostRecent
            case .raw:
                result = []
            }
        }
        
        return result
    }
    
    func getInterval(timeUnit: String, timeUnitLength: Int) -> DateComponents {
        var interval = DateComponents()
        
        if let timeUnitEnum = TimeUnitEnum(rawValue: timeUnit) {
            switch timeUnitEnum {
            case .milliseconds, .seconds:
                interval.second = timeUnitLength
            case .minute:
                interval.minute = timeUnitLength
            case .hour:
                interval.hour = timeUnitLength
            case .day:
                interval.day = timeUnitLength
            case .week:
                interval.weekOfYear = timeUnitLength
            case .month:
                interval.month = timeUnitLength
            case .year:
                interval.year = timeUnitLength
            }
        } else {
            interval.day = timeUnitLength
        }
        
        return interval
    }
    
    func processCategoryTypeQueryResult(result: [HKCategorySample], andType type: AdvancedQueryResultType, operationType: String) -> AdvancedQueryResponse {
        var rawDataArray = [AdvancedQueryResponseBlock]()
        var dataPointArray = [AdvancedQueryDataPoint]()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let isMostRecent = operationType == OperationTypeEnum.mostRecent.rawValue
        
        result.enumerated().forEach { item in
            var values: [Double]?
            if let minute = (item.element.endDate - item.element.startDate).minute {
                values = [Double(minute)]
            }
            
            if type.contains(.rawDataType) {
                let sleepType = item.element.value == HKCategoryValueSleepAnalysis.inBed.rawValue ? "InBed": "Asleep"
                let additionalData = AdditionalData(type: sleepType, value: String(item.element.value)).encode()
                
                rawDataArray += [
                    AdvancedQueryResponseBlock(
                        block: item.offset,
                        startDate: Int(item.element.startDate.timeIntervalSince1970),
                        endDate: Int(item.element.endDate.timeIntervalSince1970),
                        values: values,
                        additionalData: additionalData,
                        recordMetadataList: isMostRecent ? [item.element.healthRecordMetadata()] : nil
                    )
                ]
            }
            
            if type.contains(.dataPointType), let value = values?.first {
                dataPointArray += [AdvancedQueryDataPoint(label: dateFormatter.string(from: item.element.startDate), value: value)]
            }
        }
        
        return AdvancedQueryResponse(results: rawDataArray.toOptional, resultDataPoints: dataPointArray.toOptional)
    }
    
    func processCorrelationQueryResult(result: [HKCorrelation], andType type: AdvancedQueryResultType, firstType: HKQuantityType, secondType: HKQuantityType, operationType: String) -> AdvancedQueryResponse {
        var rawDataArray = [AdvancedQueryResponseBlock]()
        var dataPointArray = [AdvancedQueryDataPoint]()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let isMostRecent = operationType == OperationTypeEnum.mostRecent.rawValue
        
        result.enumerated().forEach { item in
            var startDate: Date?
            var endDate: Date?
            var values: [Double]?
            var metadata: HealthRecordMetadata?
            
            if let systolic = item.element.objects(for: firstType).first as? HKQuantitySample,
               let diastolic = item.element.objects(for: secondType).first as? HKQuantitySample {
                startDate = systolic.startDate
                endDate = systolic.endDate
                values = [systolic.quantity.doubleValue(for: .millimeterOfMercury()), diastolic.quantity.doubleValue(for: .millimeterOfMercury())]
                
                if isMostRecent {
                    metadata = item.element.healthRecordMetadata()
                }
            }
            
            if type.contains(.rawDataType) {
                rawDataArray += [
                    AdvancedQueryResponseBlock(
                        block: item.offset,
                        startDate: startDate.map { Int($0.timeIntervalSince1970) },
                        endDate: endDate.map { Int($0.timeIntervalSince1970) },
                        values: values,
                        recordMetadataList: metadata.map { [$0] }
                        
                    )
                ]
            }
            
            if type.contains(.dataPointType), let startDate = startDate, let values = values {
                values.forEach { dataPointArray += [AdvancedQueryDataPoint(label: dateFormatter.string(from: startDate), value: $0)] }
            }
        }
        
        return AdvancedQueryResponse(results: rawDataArray.toOptional, resultDataPoints: dataPointArray.toOptional)
    }
    
    func fetchSamples(from workout: HKWorkout, for variables: [HealthTypeEnum], _ completion: @escaping ([AdvancedQueryResponseBlock]?) -> Void) {
        guard !variables.isEmpty else { return completion(nil) }
        
        let workoutPredicate = HKQuery.predicateForObjects(from: workout)
        let sortDescriptorArray = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        
        var rawDataArray = [AdvancedQueryResponseBlock]()
        let healthKitVariables = self.healthTypes.allVariablesDict.filter { variables.map { $0.rawValue }.contains($0.key) }.values.flatMap { $0 }
        
        let queryDescriptorArray = healthKitVariables.map { HKQueryDescriptor(sampleType: $0.sampleType, predicate: workoutPredicate) }

        self.store?.executeSampleQuery(queryDescriptorArray, limit: 0, and: sortDescriptorArray) { result in
            switch result {
            case .success(let data):
                guard let sampleArray = data as? [HKQuantitySample] else { break }
                rawDataArray += sampleArray.enumerated().map { sample in
                    var valueArray: [Double]?

                    let healthKitVariable = healthKitVariables.filter({ $0.quantityType == sample.element.quantityType }).first
                    if let unit = healthKitVariable?.unit {
                        valueArray = [sample.element.quantity.doubleValue(for: unit)]
                    }

                    return AdvancedQueryResponseBlock(
                        block: sample.offset,
                        startDate: Int(sample.element.startDate.timeIntervalSince1970),
                        endDate: Int(sample.element.endDate.timeIntervalSince1970),
                        values: valueArray,
                        additionalData: healthKitVariable?.name
                    )
                }
            case .failure:
                break
            }

            completion(rawDataArray.toOptional)
        }
    }
    
    func processResults(for workouts: [HKWorkout], with mapping: WorkoutTypeVariableDictionary, _ completion: @escaping (WorkoutAdvancedQueryResponse) -> Void) {
        var rawDataArray = [WorkoutAdvancedQueryResponseBlock]()
        let group = DispatchGroup()
        
        defer {
            group.notify(queue: .main) {
                completion(WorkoutAdvancedQueryResponse(results: rawDataArray.toOptional))
            }
        }
        
        var workoutTypeVariableDict = [HKWorkoutActivityType: VariableType]()
        
        workouts.forEach { workout in
            var variable = VariableType()
            
            if let workoutVariables = workoutTypeVariableDict[workout.workoutActivityType] {
                variable = workoutVariables
            } else {
                let filteredMaps = mapping
                    .filter {
                        $0.key.workoutTypeEnums()
                            .map { self.healthTypes.workoutActivityTypesDict[$0.rawValue] }
                            .contains(workout.workoutActivityType)
                    }
                variable = filteredMaps.map { $0.value }.reduce(VariableType(), { $0.union($1) })
                workoutTypeVariableDict[workout.workoutActivityType] = variable
            }
            
            var totalEnergyBurned: Double?
            if variable.contains(.activeEnergyBurned), let unit = self.healthTypes.activeEnergyBurned.unit {
                if #available(iOS 16, *) {
                    if let quantityType = self.healthTypes.activeEnergyBurned.quantityType {
                        totalEnergyBurned = workout.statistics(for: quantityType)?.sumQuantity()?.doubleValue(for: unit)
                    }
                } else {
                    totalEnergyBurned = workout.totalEnergyBurned?.doubleValue(for: unit)
                }
            }
            
            var totalDistance: Double?
            if variable.contains(.distance), let unit = self.healthTypes.distance.unit {
                totalDistance = self.getDistanceForWorkout(workout, unit: unit)
            }
            
            let remainingVariables = variable.healthTypes().filter { $0 != .activeEnergyBurned && $0 != .distance }
            
            group.enter()
            self.fetchSamples(from: workout, for: remainingVariables) {
                rawDataArray += [
                    WorkoutAdvancedQueryResponseBlock(
                        activity: workout.workoutActivityType.name,
                        startDate: Int(workout.startDate.timeIntervalSince1970),
                        endDate: Int(workout.endDate.timeIntervalSince1970),
                        duration: workout.duration,
                        totalEnergyBurned: totalEnergyBurned,
                        totalDistance: totalDistance,
                        samples: $0,
                        recordMetadata: workout.healthRecordMetadata()
                    )
                ]
                group.leave()
            }
        }
    }
    
    /// Returns the distance for a given workout, using the appropriate distance type based on workout activity.
    /// - Parameters:
    ///   - workout: The `HKWorkout` object.
    ///   - unit: The `HKUnit` in which to return the distance (e.g., `.meter()`).
    /// - Returns: The distance as a `Double`, or `nil` if unavailable.
    private func getDistanceForWorkout(_ workout: HKWorkout, unit: HKUnit) -> Double? {
        if #available(iOS 16.0, *) {
            let distanceTypeIdentifier = self.healthTypes.distanceTypeIdentifier(for: workout.workoutActivityType)
            
            guard let identifier = distanceTypeIdentifier,
                  let quantityType = HKQuantityType.quantityType(forIdentifier: identifier),
                  let quantity = workout.statistics(for: quantityType)?.sumQuantity() else {
                return nil
            }
            return quantity.doubleValue(for: unit)
        } else {
            return workout.totalDistance?.doubleValue(for: unit)
        }
    }
    
    func getPredicate(_ startDate: Date, _ endDate: Date, _ operationType: String) -> (predicate: NSPredicate, limit: Int) {
        var startDatePredicate = startDate
        var limit = 0
        if OperationTypeEnum.mostRecent.rawValue == operationType {
            startDatePredicate = Date.distantPast
            limit = 1
        }
        
        return (HKQuery.predicateForSamples(withStart: startDatePredicate, end: endDate, options: [.strictEndDate]), limit)
    }
    
    private func executeRawQuery(types: [HealthKitVariable], startDate: Date, endDate: Date, timeUnit: String, timeUnitLength: Int, unit: HKUnit, resultType: AdvancedQueryResultType, completion: @escaping (Result<AdvancedQueryResponse, Error>) -> Void) {
        
        guard let variable = types.first else {
            completion(.failure(HealthKitErrors.variableNotAvailable))
            return
        }
        
        let sampleType: HKSampleType = variable.correlationType ?? variable.sampleType
        let interval = getInterval(timeUnit: timeUnit, timeUnitLength: timeUnitLength)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        executeSimpleQuery(forStartDate: startDate,
                           endDate: endDate,
                           sample: sampleType,
                           operationType: OperationTypeEnum.raw.rawValue,
                           sortDescriptorArray: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { data in
            
            let samples = data ?? []
            let grouped = self.groupSamplesByInterval(samples: samples, startDate: startDate, endDate: endDate, interval: interval)
            var rawDataArray = [AdvancedQueryResponseBlock]()
            var dataPointArray = [AdvancedQueryDataPoint]()
            
            for (index, (blockStart, blockEnd, blockSamples)) in grouped.enumerated() {
                var values: [Double] = []
                var metadata: [HealthRecordMetadata] = []

                for sample in blockSamples {

                    if let item = sample as? HKQuantitySample {
                        let rawValue = item.quantity.doubleValue(for: unit)
                        let value = self.convertToUnit(rawValue, unit: unit)
                        values.append(value)
                        metadata.append(item.healthRecordMetadata())

                        if resultType.contains(.dataPointType) {
                            dataPointArray.append(AdvancedQueryDataPoint(label: formatter.string(from: sample.startDate), value: value))
                        }

                    } else if let item = sample as? HKCategorySample {
                        let minutes = (item.endDate - item.startDate).minute ?? 0
                        let rawValue = Double(minutes)
                        let value = self.convertToUnit(rawValue, unit: unit)
                        values.append(value)
                        metadata.append(item.healthRecordMetadata())

                        if resultType.contains(.dataPointType) {
                            dataPointArray.append(AdvancedQueryDataPoint(label: formatter.string(from: sample.startDate), value: value))
                        }

                    } else if let item = sample as? HKCorrelation,
                              let systolicType = types[0].quantityType,
                              let diastolicType = types[1].quantityType,
                              let systolic = item.objects(for: systolicType).first as? HKQuantitySample,
                              let diastolic = item.objects(for: diastolicType).first as? HKQuantitySample {
            
                        let systolicValue = systolic.quantity.doubleValue(for: .millimeterOfMercury()).jsSafe()
                        let diastolicValue = diastolic.quantity.doubleValue(for: .millimeterOfMercury()).jsSafe()
                        let correlationValues = [systolicValue, diastolicValue]
                        
                        values.append(contentsOf: correlationValues)
                        metadata.append(item.healthRecordMetadata())
                        metadata.append(item.healthRecordMetadata())

                        if resultType.contains(.dataPointType) {
                            correlationValues.forEach {
                                dataPointArray.append(AdvancedQueryDataPoint(label: formatter.string(from: systolic.startDate), value: $0))
                            }
                        }
                    }
                }

                if resultType.contains(.rawDataType) {
                    rawDataArray.append(
                        AdvancedQueryResponseBlock(
                            block: index,
                            startDate: Int(blockStart.timeIntervalSince1970),
                            endDate: Int(blockEnd.timeIntervalSince1970),
                            values: values,
                            recordMetadataList: metadata
                        )
                    )
                }
            }

            completion(.success(AdvancedQueryResponse(results: rawDataArray.toOptional, resultDataPoints: dataPointArray.toOptional)))
        }
    }
    
    private func executeMinMaxWithMetadata(types: [HealthKitVariable], startDate: Date, endDate: Date, timeUnit: String, timeUnitLength: Int, unit: HKUnit, operationType: String, resultType: AdvancedQueryResultType, completion: @escaping (Result<AdvancedQueryResponse, Error>) -> Void) {
        
        guard let variable = types.first else {
            completion(.success(AdvancedQueryResponse(results: nil, resultDataPoints: nil)))
            return
        }
        
        let sampleType: HKSampleType = variable.sampleType
        let interval = getInterval(timeUnit: timeUnit, timeUnitLength: timeUnitLength)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        executeSimpleQuery(forStartDate: startDate,
                           endDate: endDate,
                           sample: sampleType,
                           operationType: OperationTypeEnum.raw.rawValue,
                           sortDescriptorArray: []) { data in
            
            let samples = data ?? []
            let grouped = self.groupSamplesByInterval(samples: samples, startDate: startDate, endDate: endDate, interval: interval)
            var rawDataArray: [AdvancedQueryResponseBlock] = []
            var dataPointArray: [AdvancedQueryDataPoint] = []
            
            for (index, (blockStart, blockEnd, blockSamples)) in grouped.enumerated() {
                var selectedValue: Double = 0
                var selectedSample: HKSample?
                
                if let quantitySamples = blockSamples as? [HKQuantitySample], !quantitySamples.isEmpty {
                    let selected: HKQuantitySample?
                    
                    if operationType == OperationTypeEnum.min.rawValue {
                        selected = quantitySamples.min { $0.quantity.doubleValue(for: unit) < $1.quantity.doubleValue(for: unit)}
                    } else {
                        selected = quantitySamples.max { $0.quantity.doubleValue(for: unit) < $1.quantity.doubleValue(for: unit)}
                    }
                    
                    guard let selected = selected else { continue }
                    let rawValue = selected.quantity.doubleValue(for: unit)
                    selectedValue = self.convertToUnit(rawValue, unit: unit)
                    selectedSample = selected
                    
                } else if let categorySamples = blockSamples as? [HKCategorySample], !categorySamples.isEmpty {
                    let durations = categorySamples.map { Double(($0.endDate - $0.startDate).minute ?? 0)}
                    let rawValue = operationType == OperationTypeEnum.min.rawValue ? (durations.min() ?? 0) : (durations.max() ?? 0)
                    selectedValue = self.convertToUnit(rawValue, unit: unit)
                    selectedSample = categorySamples.first
                }
                
                if resultType.contains(.rawDataType) {
                    rawDataArray.append(
                        AdvancedQueryResponseBlock(
                            block: index,
                            startDate: Int(blockStart.timeIntervalSince1970),
                            endDate: Int(blockEnd.timeIntervalSince1970),
                            values: [selectedValue],
                            recordMetadataList: selectedSample.map { [$0.healthRecordMetadata()] }
                        )
                    )
                }
                
                if resultType.contains(.dataPointType), let selectedSample = selectedSample {
                    dataPointArray.append(AdvancedQueryDataPoint(label: formatter.string(from: selectedSample.startDate), value: selectedValue))
                }
            }
            completion(.success(AdvancedQueryResponse(results: rawDataArray.toOptional, resultDataPoints: dataPointArray.toOptional)))
        }
    }
    
    func groupSamplesByInterval<T: HKSample>(samples: [T], startDate: Date, endDate: Date,interval: DateComponents) -> [(blockStart: Date, blockEnd: Date, samples: [T])] {

        var result: [(Date, Date, [T])] = []
        var blockStart = startDate

        while blockStart < endDate {
            let blockEnd = Calendar.current.date(byAdding: interval, to: blockStart)!

            let blockSamples = samples.filter {
                $0.startDate >= blockStart && $0.startDate < blockEnd
            }

            if !blockSamples.isEmpty {
                result.append((blockStart, blockEnd, blockSamples))
            }

            blockStart = blockEnd
        }

        return result
    }
    
    func convertToUnit(_ value: Double, unit: HKUnit) -> Double {
        var result = value
        
        if unit == .percent() && result != 0 {
            result = round(1000 * (result * 100)) / 1000
        }
        
        return result.jsSafe()
    }
    
    func executeSimpleQuery(forStartDate startDate: Date, endDate: Date, sample: HKSampleType, operationType: String, sortDescriptorArray: [NSSortDescriptor], completion: @escaping ([HKSample]?) -> Void) {
        guard let startDate = NSCalendar.current.date(from: self.getCalendarComponent(date: startDate)),
              let endDate = NSCalendar.current.date(from: self.getCalendarComponent(date: endDate))
        else {
            completion(nil)
            return
        }
        
        let predicateResult = getPredicate(startDate, endDate, operationType)
        
        self.store?.executeSimpleQuery(
            sample: sample, predicate: predicateResult.predicate, limit: predicateResult.limit, sortDescriptors: sortDescriptorArray
        ) { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure:
                completion(nil)
            }
        }
    }
    
    func executeWorkoutQuery(for sample: HKSampleType, with workoutActivityTypeArray: [HKWorkoutActivityType]?, _ startDate: Date, _ endDate: Date, and sortDescriptorArray: [NSSortDescriptor], _ completion: @escaping ([HKSample]?) -> Void) {
        guard let startDate = NSCalendar.current.date(from: self.getCalendarComponent(date: startDate)),
                let endDate = NSCalendar.current.date(from: self.getCalendarComponent(date: endDate))
        else {
            completion(nil)
            return
        }
        
        var predicateArray = [HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictEndDate])]
        if let workoutActivityTypeArray = workoutActivityTypeArray {
            let workoutPredicateArray = workoutActivityTypeArray.map { HKQuery.predicateForWorkouts(with: $0) }
            predicateArray += [NSCompoundPredicate(orPredicateWithSubpredicates: workoutPredicateArray)]
        }
        
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        
        self.store?.executeSimpleQuery(
            sample: sample, predicate: compound, limit: 0, sortDescriptors: sortDescriptorArray
        ) { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure:
                completion(nil)
            }
        }
    }
    
    func resolveTrigerJob(comparision: String, currentValue: Double, triggerValue: Double) -> Bool {
        var comparator: (Double, Double) -> Bool = (<=)
        
        if let comparisionOperation = ComparisionOperationEnum(rawValue: comparision) {
            switch comparisionOperation {
            case ComparisionOperationEnum.equal:
                comparator = (==)
            case ComparisionOperationEnum.greater:
                comparator = (>)
            case ComparisionOperationEnum.less:
                comparator = (<)
            case ComparisionOperationEnum.greaterOrEqual:
                comparator = (>=)
            default:
                break
            }
        }
        
        return comparator(currentValue, triggerValue)
    }
    
    func performQuery(
        variable: String,
        date: (start: Date, end: Date),
        timeUnit: String,
        operationType: String,
        mostRecent: Bool,
        comparision: String,
        notificationID: String,
        notificationText: (header: String, body: String),
        triggerValue: Double,
        backgroundJobID: Int64,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        self.advancedQuery(
            variable: variable,
            startDate: date.start,
            endDate: date.end,
            timeUnit: timeUnit,
            operationType: operationType,
            mostRecent: mostRecent,
            timeUnitLength: 1
        ) { [weak self] result, _ in
            guard let self = self else { return }
            
            if let result = result {
                let currentValue = result.results?.first?.values?.first ?? 0
                if self.resolveTrigerJob(comparision: comparision, currentValue: currentValue, triggerValue: triggerValue) {
                    do {
                        try self.backgroundManager?.updateBackgroundJob(id: backgroundJobID, lastNotificationTimestamp: Date())
                        self.scheduleNotification(header: notificationText.header, body: notificationText.body, andId: String(notificationID))
                    } catch {
                        completion(.failure(error))
                        return
                    }
                }
                
                completion(.success(true))
            }
        }
    }
}
