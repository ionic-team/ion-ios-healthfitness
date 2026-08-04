import HealthKit

protocol HealthKitManagerProtocol {
    func executeAnchoredObjectQuery(
        type: HKSampleType,
        predicate: NSPredicate?,
        anchor: HKQueryAnchor?,
        limit: Int,
        resultsHandler: @escaping (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?, Bool) -> Void
    )
    func executeObserverQuery(sampleType: HKSampleType, predicate: NSPredicate?, updateHandler: @escaping (HKObserverQuery, @escaping HKObserverQueryCompletionHandler, Error?) -> Void)
    func checkAuthorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus
    func writeData(sample: HKQuantitySample, completion: @escaping (_ inner: @escaping CompletionHandler) -> Void)
    func executeAdvancedQuery(
        quantityType: HKQuantityType,
        options: HKStatisticsOptions,
        anchorDate: Date,
        interval: DateComponents,
        date: (start: Date, end: Date),
        mostRecent: Bool,
        onlyFilledBlocks: Bool,
        resultType: AdvancedQueryResultType,
        unit: HKUnit,
        completion: @escaping (Result<AdvancedQueryResponse, Error>) -> Void
    )
    func executeSimpleQuery(sample: HKSampleType, predicate: NSPredicate, limit: Int, sortDescriptors: [NSSortDescriptor], completion: @escaping (Result<[HKSample]?, Error>) -> Void)
    func requestAuthorization(setToWrite: Set<HKSampleType>?, setToRead: Set<HKObjectType>?, completion: @escaping (Bool, NSError?) -> Void)
    func enableBackgroundDelivery(for type: HKObjectType, andFrequency frequency: HKUpdateFrequency, completion: @escaping (Result<Bool, Error>) -> Void)
    func disableAllBackgroundDeliveries(completion: @escaping (Result<Bool, Error>) -> Void)
    func disableBackgroundDeliveryFor(type: HKObjectType, completion: @escaping (Result<Bool, Error>) -> Void)
    
    @available(iOS 15, *)
    func executeSampleQuery(_ queryDescriptors: [HKQueryDescriptor], limit: Int, and sortDescriptors: [NSSortDescriptor], _ completion: @escaping (Result<[HKSample]?, Error>) -> Void)
}

extension HKHealthStore: HealthKitManagerProtocol {
    func executeObserverQuery(sampleType: HKSampleType, predicate: NSPredicate?, updateHandler: @escaping (HKObserverQuery, @escaping HKObserverQueryCompletionHandler, Error?) -> Void) {
        let query = HKObserverQuery(sampleType: sampleType, predicate: predicate, updateHandler: updateHandler)
        self.execute(query)
    }
    
    func executeAnchoredObjectQuery(
        type: HKSampleType,
        predicate: NSPredicate?,
        anchor: HKQueryAnchor?,
        limit: Int,
        resultsHandler: @escaping (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?, Bool) -> Void
    ) {
        let queryAnchored = HKAnchoredObjectQuery(
            type: type,
            predicate: predicate,
            anchor: anchor,
            limit: limit
        ) { query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil in
            let hasChanges = anchor != newAnchor && anchor != HKQueryAnchor(fromValue: 0)
            resultsHandler(query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil, hasChanges)
        }
        self.execute(queryAnchored)
    }
    
    func disableBackgroundDeliveryFor(type: HKObjectType, completion: @escaping (Result<Bool, Error>) -> Void) {
        self.disableBackgroundDelivery(for: type) { succeeded, error in
            if succeeded {
                completion(.success(true))
            } else if let err = error {
                completion(.failure(err))
            }
        }
    }
    
    func disableAllBackgroundDeliveries(completion: @escaping (Result<Bool, Error>) -> Void) {
        self.disableAllBackgroundDelivery { succeeded, error in
            if succeeded {
                completion(.success(true))
            } else if let err = error {
                completion(.failure(err))
            }
        }
    }
    
    func enableBackgroundDelivery(for type: HKObjectType, andFrequency frequency: HKUpdateFrequency, completion: @escaping (Result<Bool, Error>) -> Void) {
        self.enableBackgroundDelivery(for: type, frequency: frequency) { succeeded, error in
            if succeeded {
                completion(.success(true))
            } else if let err = error {
                completion(.failure(err))
            }
        }
    }
    
    func requestAuthorization(setToWrite: Set<HKSampleType>?, setToRead: Set<HKObjectType>?, completion: @escaping (Bool, NSError?) -> Void) {
        self.requestAuthorization(toShare: setToWrite, read: setToRead) { success, error in
            if success {
                completion(success, error as NSError?)
            } else {
                completion(false, HealthKitErrors.authorizationError as NSError)
            }
        }
    }
    
    func checkAuthorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        return self.authorizationStatus(for: type)
    }
    
    func executeAdvancedQuery(
        quantityType: HKQuantityType,
        options: HKStatisticsOptions,
        anchorDate: Date,
        interval: DateComponents,
        date: (start: Date, end: Date),
        mostRecent: Bool,
        onlyFilledBlocks: Bool,
        resultType: AdvancedQueryResultType,
        unit: HKUnit,
        completion: @escaping (Result<AdvancedQueryResponse, Error>) -> Void
    ) {
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: options,
            anchorDate: anchorDate,
            intervalComponents: interval
        )
        query.initialResultsHandler = { _, results, error in
            if let error = error {
                completion(.failure(error))
            } else if let results = results {
                let data = self.processAdvancedQueryResult(
                    newStartDate: date.start,
                    endDate: date.end,
                    mostRecent: mostRecent,
                    onlyFilledBlocks: onlyFilledBlocks,
                    resultType: resultType,
                    unit: unit,
                    result: results
                )
                completion(.success(data))
            }
        }
        
        self.execute(query)
    }
    
    func executeSimpleQuery(
        sample: HKSampleType,
        predicate: NSPredicate,
        limit: Int,
        sortDescriptors: [NSSortDescriptor],
        completion: @escaping (Result<[HKSample]?, Error>) -> Void
    ) {
        let sampleQuery = HKSampleQuery(
            sampleType: sample,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { _, results, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(results))
            }
        }
        self.execute(sampleQuery)
    }
    
    @available(iOS 15, *)
    func executeSampleQuery(_ queryDescriptors: [HKQueryDescriptor], limit: Int, and sortDescriptors: [NSSortDescriptor], _ completion: @escaping (Result<[HKSample]?, Error>) -> Void) {
        let sampleQuery = HKSampleQuery(queryDescriptors: queryDescriptors, limit: limit, sortDescriptors: sortDescriptors) { _, results, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(results))
            }
        }
        self.execute(sampleQuery)
    }
    
    func writeData(sample: HKQuantitySample, completion: @escaping (@escaping CompletionHandler) -> Void) {
        self.save(sample) { _, error in
            if let error = error {
                completion({ throw error })
            } else {
                completion({ nil })
            }
        }
    }
}

private extension HKHealthStore {
    func resolveBlockValue(statistics: HKStatistics, unit: HKUnit, mostRecent: Bool) -> Double {
        var resultValue: Double = 0
        
        if mostRecent {
            if let mostRecentQuantity = statistics.mostRecentQuantity() {
                resultValue = mostRecentQuantity.doubleValue(for: unit)
            }
        } else {
            if let maxQuantity = statistics.maximumQuantity() {
                resultValue = maxQuantity.doubleValue(for: unit)
            } else if let minimumQuantity = statistics.minimumQuantity() {
                resultValue = minimumQuantity.doubleValue(for: unit)
            } else if let averageQuantity = statistics.averageQuantity() {
                resultValue = averageQuantity.doubleValue(for: unit)
            } else if let sum = statistics.sumQuantity() {
                resultValue = round(sum.doubleValue(for: unit) * 100) / 100.0
            }
        }
        
        // in this case, we should return a percentage, thus the '* 100' (e.g. 97%),
        // and round the value at the third decimal case (e.g. 97.343%)
        if unit == .percent() && resultValue != 0 {
            resultValue = round(1000 * (resultValue * 100) ) / 1000
        }
        
        return resultValue.jsSafe()
    }
    
    func processAdvancedQueryResult(newStartDate: Date, endDate: Date, mostRecent: Bool, onlyFilledBlocks: Bool, resultType: AdvancedQueryResultType, unit: HKUnit, result: HKStatisticsCollection) -> AdvancedQueryResponse {
        var rawDataArray = [AdvancedQueryResponseBlock]()
        var dataPointArray = [AdvancedQueryDataPoint]()
        let dateRange = newStartDate..<endDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        result.enumerateStatistics(from: newStartDate, to: endDate) { statistics, _ in
            guard dateRange.contains(statistics.startDate) else { return }
            let resultValue = self.resolveBlockValue(statistics: statistics, unit: unit, mostRecent: mostRecent)
            
            if !onlyFilledBlocks || resultValue != 0 {
                if resultType.contains(.rawDataType) {
                    rawDataArray += [
                        AdvancedQueryResponseBlock(
                            block: rawDataArray.count,
                            startDate: Int(statistics.startDate.timeIntervalSince1970),
                            endDate: Int(statistics.endDate.timeIntervalSince1970),
                            values: [resultValue]
                        )
                    ]
                }
                
                if resultType.contains(.dataPointType) {
                    dataPointArray += [
                        AdvancedQueryDataPoint(label: dateFormatter.string(from: statistics.startDate), value: resultValue)
                    ]
                }
            }
        }
        
        return AdvancedQueryResponse(results: rawDataArray.toOptional, resultDataPoints: dataPointArray.toOptional)
    }
}
