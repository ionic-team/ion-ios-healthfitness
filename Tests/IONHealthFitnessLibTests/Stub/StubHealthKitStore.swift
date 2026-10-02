import HealthKit
@testable import IONHealthFitnessLib

class StubHealthKitStore: HealthKitManagerProtocol {
    func executeSimpleQuery(
        sample: HKSampleType, predicate: NSPredicate,
        limit: Int,
        sortDescriptors: [NSSortDescriptor],
        completion: @escaping (Result<[HKSample]?, Error>) -> Void
    ) {
        completion(didExecuteSimpleQuery ? .success(nil) : .failure(HealthKitErrors.errorWhileReading))
    }
    
    func executeAnchoredObjectQuery(
        type: HKSampleType,
        predicate: NSPredicate?,
        anchor: HKQueryAnchor?,
        limit: Int,
        resultsHandler: @escaping (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?, Bool) -> Void
    ) {
        let queryAnchored = HKAnchoredObjectQuery(type: type, predicate: predicate, anchor: anchor, limit: limit, resultsHandler: { _, _, _, _, _ in
            print("Nothing to do here.")
        })
        resultsHandler(queryAnchored, nil, nil, HKQueryAnchor(fromValue: -1), nil, true)
    }
    
    func executeObserverQuery(
        sampleType: HKSampleType,
        predicate: NSPredicate?,
        updateHandler: @escaping (HKObserverQuery, @escaping HKObserverQueryCompletionHandler, Error?) -> Void
    ) {
        let query = HKObserverQuery(sampleType: sampleType, predicate: predicate, updateHandler: updateHandler)
        updateHandler(query, {}, nil)
    }
    
    var didExecuteSimpleQuery = false
    var didPermissionsGrantWithoutError = false
    var didWriteSteps = false
    var didAdvancedQuery = false
    var currentAuthorizationStatus: HKAuthorizationStatus = .notDetermined
    var didEnableBackgroundJobDelivery = false
    var advancedQueryResponse = AdvancedQueryResponse()
    
    func requestAuthorization(setToWrite: Set<HKSampleType>?, setToRead: Set<HKObjectType>?, completion: @escaping (Bool, NSError?) -> Void) {
        if didPermissionsGrantWithoutError {
            completion(true, nil)
        } else {
            completion(false, HealthKitErrors.authorizationError as NSError)
        }
    }
    
    func executeAdvancedQuery(
        quantityType: HKQuantityType,
        options: HKStatisticsOptions,
        anchorDate: Date,
        interval: DateComponents,
        date: (start: Date, end: Date),
        mostRecent: Bool,
        onlyFilledBlocks: Bool = false,
        resultType: AdvancedQueryResultType = .allType,
        unit: HKUnit,
        completion: @escaping (Result<AdvancedQueryResponse, Error>) -> Void
    ) {
        completion(didAdvancedQuery ? .success(advancedQueryResponse) : .failure(HealthKitErrors.errorWhileReading))
    }
    
    func executeSimpleQuery(
        sample: HKSampleType,
        predicate: NSPredicate,
        limit: Int,
        sortDescriptors: [NSSortDescriptor],
        completion: @escaping (Result<[HKCorrelation]?, Error>) -> Void
    ) {
        completion(didExecuteSimpleQuery ? .success(nil) : .failure(HealthKitErrors.errorWhileReading))
    }
    
    func writeData(sample: HKQuantitySample, completion: @escaping (@escaping () throws -> HealthKitErrors?) -> Void) {
        completion(!didWriteSteps ? { throw HealthKitErrors.errorWhileWriting } : { nil })
    }
    
    func checkAuthorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus { self.currentAuthorizationStatus }
    
    func setAuthorizationStatus(status: HKAuthorizationStatus) {
        self.currentAuthorizationStatus = status
    }
    
    func setDidWriteSteps(_ value: Bool) {
        self.didWriteSteps = value
    }
    
    func setDidAdvancedQuery(_ value: Bool) {
        self.didAdvancedQuery = value
    }
    
    func setDidPermissionsGrantWithoutError(_ value: Bool) {
        self.didPermissionsGrantWithoutError = value
    }
    
    func setDidEnableBackgroundJobDelivery(_ value: Bool) {
        self.didEnableBackgroundJobDelivery = value
    }
    
    func enableBackgroundDelivery(for type: HKObjectType, andFrequency frequency: HKUpdateFrequency, completion: @escaping (Result<Bool, Error>) -> Void) {
        if didEnableBackgroundJobDelivery {
            // send success in completion
            completion(.success(true))
        }
    }
    
    func execute(query: HKQuery) {}
    func disableAllBackgroundDeliveries(completion: @escaping (Result<Bool, Error>) -> Void) {}
    func disableBackgroundDeliveryFor(type: HKObjectType, completion: @escaping (Result<Bool, Error>) -> Void) {}
    func executeSampleQuery(_ queryDescriptors: [HKQueryDescriptor], limit: Int, and sortDescriptors: [NSSortDescriptor], _ completion: @escaping (Result<[HKSample]?, Error>) -> Void) {}
}
