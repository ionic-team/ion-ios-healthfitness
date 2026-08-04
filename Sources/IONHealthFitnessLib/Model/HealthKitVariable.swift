import HealthKit

struct HealthKitVariable {
    var quantityType: HKQuantityType?
    var sampleType: HKSampleType
    var objectType: HKObjectType
    var correlationType: HKCorrelationType?
    var categoryType: HKCategoryType?
    var unit: HKUnit?
    var optionsAllowed: [HKStatisticsOptions]?
    
    var workoutType: HKWorkoutType?
    
    var name: String
    
    init(
        quantityType: HKQuantityType? = nil,
        correlationType: HKCorrelationType? = nil,
        categoryType: HKCategoryType? = nil,
        workoutType: HKWorkoutType? = nil,
        unit: HKUnit? = nil,
        optionsAllowed: [HKStatisticsOptions]? = nil,
        name: String
    ) {
        self.quantityType = quantityType
        self.correlationType = correlationType
        self.categoryType = categoryType
        self.workoutType = workoutType
        self.unit = unit
        self.optionsAllowed = optionsAllowed
        
        let workoutOrCategoryOrQuantityType = workoutType ?? categoryType ?? quantityType!
        
        self.sampleType = workoutOrCategoryOrQuantityType
        self.objectType = workoutOrCategoryOrQuantityType
        
        self.name = name
    }
    
    init(quantityTypeIdentifier: HKQuantityTypeIdentifier, unit: HKUnit, optionsAllowed: [HKStatisticsOptions], name: String) {
        self.init(
            quantityType: HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier),
            unit: unit,
            optionsAllowed: optionsAllowed,
            name: name
        )
    }
    
    init(quantityTypeIdentifier: HKQuantityTypeIdentifier, correlationTypeIdentifier: HKCorrelationTypeIdentifier, unit: HKUnit, name: String) {
        self.init(
            quantityType: HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier),
            correlationType: HKCorrelationType.correlationType(forIdentifier: correlationTypeIdentifier),
            unit: unit,
            name: name
        )
    }
    
    init(categoryTypeIdentifier: HKCategoryTypeIdentifier, unit: HKUnit, optionsAllowed: [HKStatisticsOptions], name: String) {
        self.init(
            categoryType: HKCategoryType.categoryType(forIdentifier: categoryTypeIdentifier),
            unit: unit,
            optionsAllowed: optionsAllowed,
            name: name
        )
    }
    
    static func initWorkoutType(name: String) -> HealthKitVariable {
        Self.init(
            workoutType: HKWorkoutType.workoutType(),
            name: name
        )
    }
    
}
