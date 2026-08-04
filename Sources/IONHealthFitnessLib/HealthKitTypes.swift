import HealthKit

class HealthKitTypes {
    lazy var cumulativeSumOperations: [HKStatisticsOptions] = [.cumulativeSum]
    lazy var averageOperations: [HKStatisticsOptions] = [.discreteAverage, .discreteMax, .discreteMin]
    lazy var walkingSpeed: HealthKitVariable = {
        let quantityTypeIdentifier: HKQuantityTypeIdentifier
        
        if #available(iOS 14, *) {
            quantityTypeIdentifier = .walkingSpeed
        } else {
            quantityTypeIdentifier = .distanceWalkingRunning
        }
        
        return HealthKitVariable(
            quantityTypeIdentifier: quantityTypeIdentifier,
            unit: HKUnit(from: "m/s"),
            optionsAllowed: averageOperations,
            name: "Walking Speed"
        )
    }()
    lazy var distance = HealthKitVariable(
        quantityTypeIdentifier: .distanceWalkingRunning,
        unit: HKUnit.meter(),
        optionsAllowed: self.cumulativeSumOperations,
        name: "Distance Walking Running"
    )
    lazy var vo2max = HealthKitVariable(
        quantityTypeIdentifier: .vo2Max,
        unit: HKUnit(from: "mL/min·kg"),
        optionsAllowed: self.averageOperations,
        name: "VO2 Max"
    )
    lazy var stepCount = HealthKitVariable(
        quantityTypeIdentifier: .stepCount,
        unit: HKUnit.count(),
        optionsAllowed: self.cumulativeSumOperations,
        name: "Step Count"
    )
    lazy var heartRate = HealthKitVariable(
        quantityTypeIdentifier: .heartRate,
        unit: HKUnit(from: "count/min"),
        optionsAllowed: self.averageOperations,
        name: "Heart Rate"
    )
    lazy var bodyMass = HealthKitVariable(
        quantityTypeIdentifier: .bodyMass,
        unit: HKUnit.gramUnit(with: .kilo),
        optionsAllowed: self.averageOperations,
        name: "Body Mass"
    )
    lazy var height = HealthKitVariable(
        quantityTypeIdentifier: .height,
        unit: HKUnit.meterUnit(with: .centi),
        optionsAllowed: self.averageOperations,
        name: "Height"
    )
    lazy var bloodGlucose = HealthKitVariable(
        quantityTypeIdentifier: .bloodGlucose,
        unit: HKUnit(from: "mg/dL"),
        optionsAllowed: self.averageOperations,
        name: "Blood Glucose"
    )
    lazy var bloodPressureSystolic = HealthKitVariable(
        quantityTypeIdentifier: .bloodPressureSystolic,
        correlationTypeIdentifier: .bloodPressure,
        unit: HKUnit.count(),
        name: "Blood Pressure Systolic"
    )
    lazy var bloodPressureDiastolic = HealthKitVariable(
        quantityTypeIdentifier: .bloodPressureDiastolic,
        correlationTypeIdentifier: .bloodPressure,
        unit: HKUnit.count(),
        name: "Blood Pressure Diastolic"
    )
    lazy var sleepAnalysis = HealthKitVariable(
        categoryTypeIdentifier: .sleepAnalysis,
        unit: HKUnit.count(),
        optionsAllowed: self.averageOperations,
        name: "Sleep Analysis"
    )
    lazy var oxygenSaturation = HealthKitVariable(
        quantityTypeIdentifier: .oxygenSaturation,
        unit: HKUnit.percent(),
        optionsAllowed: self.averageOperations,
        name: "Oxygen Saturation"
    )
    lazy var activeEnergyBurned = HealthKitVariable(
        quantityTypeIdentifier: .activeEnergyBurned,
        unit: HKUnit.kilocalorie(),
        optionsAllowed: self.cumulativeSumOperations,
        name: "Active Energy Burned"
    )
    lazy var bodyFatPercentage = HealthKitVariable(
        quantityTypeIdentifier: .bodyFatPercentage,
        unit: HKUnit.percent(),
        optionsAllowed: self.averageOperations,
        name: "Body Fat Percentage"
    )
    lazy var basalEnergyBurned = HealthKitVariable(
        quantityTypeIdentifier: .basalEnergyBurned,
        unit: HKUnit.kilocalorie(),
        optionsAllowed: self.cumulativeSumOperations,
        name: "Basal Energy Burned"
    )
    lazy var bodyTemperature = HealthKitVariable(
        quantityTypeIdentifier: .bodyTemperature,
        unit: HKUnit.degreeCelsius(),
        optionsAllowed: self.averageOperations,
        name: "Body Temperature"
    )
    lazy var dietaryWater = HealthKitVariable(
        quantityTypeIdentifier: .dietaryWater,
        unit: HKUnit.liter(),
        optionsAllowed: self.cumulativeSumOperations,
        name: "Dietary Water"
    )
    lazy var pushCount = HealthKitVariable(
        quantityTypeIdentifier: .pushCount,
        unit: HKUnit.count(),
        optionsAllowed: self.cumulativeSumOperations,
        name: "Push Count"
    )
    lazy var dietaryEnergyConsumed = HealthKitVariable(
        quantityTypeIdentifier: .dietaryEnergyConsumed,
        unit: HKUnit.kilocalorie(),
        optionsAllowed: self.cumulativeSumOperations,
        name: "Dietary Energy Consumed"
    )
    
    // MARK: - Workout
    lazy var workout = HealthKitVariable.initWorkoutType(name: "Workout")
    
    // MARK: - All Variables
    lazy var allVariablesDict: [String: [HealthKitVariable]] = [
        HealthTypeEnum.stepCount.rawValue: [stepCount],
        HealthTypeEnum.heartRate.rawValue: [heartRate],
        HealthTypeEnum.weight.rawValue: [bodyMass],
        HealthTypeEnum.height.rawValue: [height],
        HealthTypeEnum.bloodGlucose.rawValue: [bloodGlucose],
        HealthTypeEnum.bloodPressure.rawValue: [bloodPressureSystolic, bloodPressureDiastolic],
        HealthTypeEnum.sleepAnalysis.rawValue: [sleepAnalysis],
        HealthTypeEnum.oxygenSaturation.rawValue: [oxygenSaturation],
        HealthTypeEnum.activeEnergyBurned.rawValue: [activeEnergyBurned],
        HealthTypeEnum.basalEnergyBurned.rawValue: [basalEnergyBurned],
        HealthTypeEnum.bodyFatPercentage.rawValue: [bodyFatPercentage],
        HealthTypeEnum.bodyTemperature.rawValue: [bodyTemperature],
        HealthTypeEnum.dietaryWater.rawValue: [dietaryWater],
        HealthTypeEnum.dietaryEnergyConsumed.rawValue: [dietaryEnergyConsumed],
        HealthTypeEnum.pushCount.rawValue: [pushCount],
        HealthTypeEnum.vo2max.rawValue: [vo2max],
        HealthTypeEnum.distance.rawValue: [distance],
        HealthTypeEnum.walkingSpeed.rawValue: [walkingSpeed],
        
        HealthTypeEnum.workout.rawValue: [workout]
    ]
    
    // MARK: - Profile Variables
    lazy var profileVariablesDict: [String: [HealthKitVariable]] = [
        HealthTypeEnum.weight.rawValue: [bodyMass],
        HealthTypeEnum.bodyFatPercentage.rawValue: [bodyFatPercentage],
        HealthTypeEnum.basalEnergyBurned.rawValue: [basalEnergyBurned],
        HealthTypeEnum.height.rawValue: [height]
    ]
    
    // MARK: - Fitness Variables
    lazy var fitnessVariablesDict: [String: [HealthKitVariable]] = [
        HealthTypeEnum.stepCount.rawValue: [stepCount],
        HealthTypeEnum.activeEnergyBurned.rawValue: [activeEnergyBurned],
        HealthTypeEnum.distance.rawValue: [distance],
        HealthTypeEnum.walkingSpeed.rawValue: [walkingSpeed]
    ]
    
    // MARK: - Health Variables
    lazy var healthVariablesDict: [String: [HealthKitVariable]] = [
        HealthTypeEnum.sleepAnalysis.rawValue: [sleepAnalysis],
        HealthTypeEnum.bloodPressure.rawValue: [bloodPressureSystolic, bloodPressureDiastolic],
        HealthTypeEnum.bloodGlucose.rawValue: [bloodGlucose],
        HealthTypeEnum.oxygenSaturation.rawValue: [oxygenSaturation],
        HealthTypeEnum.bodyTemperature.rawValue: [bodyTemperature],
        HealthTypeEnum.dietaryEnergyConsumed.rawValue: [dietaryEnergyConsumed],
        HealthTypeEnum.dietaryWater.rawValue: [dietaryWater],
        HealthTypeEnum.heartRate.rawValue: [heartRate]
    ]
    
    // MARK: - Workout Variables
    lazy var workoutVariablesDict: [String: [HealthKitVariable]] = allVariablesDict
    
    // MARK: - Workout Activity Types
    lazy var workoutActivityTypesDict: [String: HKWorkoutActivityType] = [
        WorkoutTypeEnum.americanFootball.rawValue: .americanFootball,
        WorkoutTypeEnum.archery.rawValue: .archery,
        WorkoutTypeEnum.australianFootball.rawValue: .australianFootball,
        WorkoutTypeEnum.badminton.rawValue: .badminton,
        WorkoutTypeEnum.barre.rawValue: .barre,
        WorkoutTypeEnum.baseball.rawValue: .baseball,
        WorkoutTypeEnum.basketball.rawValue: .basketball,
        WorkoutTypeEnum.bowling.rawValue: .bowling,
        WorkoutTypeEnum.boxing.rawValue: .boxing,
        WorkoutTypeEnum.climbing.rawValue: .climbing,
        WorkoutTypeEnum.coreTraining.rawValue: .coreTraining,
        WorkoutTypeEnum.crossCountrySkiing.rawValue: .crossCountrySkiing,
        WorkoutTypeEnum.crossTraining.rawValue: .crossTraining,
        WorkoutTypeEnum.curling.rawValue: .curling,
        WorkoutTypeEnum.cycling.rawValue: .cycling,
        WorkoutTypeEnum.dance.rawValue: .dance,
        WorkoutTypeEnum.discSports.rawValue: .discSports,
        WorkoutTypeEnum.downhillSkiing.rawValue: .downhillSkiing,
        WorkoutTypeEnum.elliptical.rawValue: .elliptical,
        WorkoutTypeEnum.equestrianSports.rawValue: .equestrianSports,
        WorkoutTypeEnum.fencing.rawValue: .fencing,
        WorkoutTypeEnum.fitnessGaming.rawValue: .fitnessGaming,
        WorkoutTypeEnum.fishing.rawValue: .fishing,
        WorkoutTypeEnum.flexibility.rawValue: .flexibility,
        WorkoutTypeEnum.functionalStrengthTraining.rawValue: .functionalStrengthTraining,
        WorkoutTypeEnum.golf.rawValue: .golf,
        WorkoutTypeEnum.gymnastics.rawValue: .gymnastics,
        WorkoutTypeEnum.handball.rawValue: .handball,
        WorkoutTypeEnum.handCycling.rawValue: .handCycling,
        WorkoutTypeEnum.highIntensityIntervalTraining.rawValue: .highIntensityIntervalTraining,
        WorkoutTypeEnum.hiking.rawValue: .hiking,
        WorkoutTypeEnum.hockey.rawValue: .hockey,
        WorkoutTypeEnum.hunting.rawValue: .hunting,
        WorkoutTypeEnum.jumpRope.rawValue: .jumpRope,
        WorkoutTypeEnum.kickboxing.rawValue: .kickboxing,
        WorkoutTypeEnum.lacrosse.rawValue: .lacrosse,
        WorkoutTypeEnum.martialArts.rawValue: .martialArts,
        WorkoutTypeEnum.mindAndBody.rawValue: .mindAndBody,
        WorkoutTypeEnum.mixedCardio.rawValue: .mixedCardio,
        WorkoutTypeEnum.paddleSports.rawValue: .paddleSports,
        WorkoutTypeEnum.pilates.rawValue: .pilates,
        WorkoutTypeEnum.play.rawValue: .play,
        WorkoutTypeEnum.preparationAndRecovery.rawValue: .preparationAndRecovery,
        WorkoutTypeEnum.racquetball.rawValue: .racquetball,
        WorkoutTypeEnum.rowing.rawValue: .rowing,
        WorkoutTypeEnum.rugby.rawValue: .rugby,
        WorkoutTypeEnum.running.rawValue: .running,
        WorkoutTypeEnum.sailing.rawValue: .sailing,
        WorkoutTypeEnum.skatingSports.rawValue: .skatingSports,
        WorkoutTypeEnum.snowboarding.rawValue: .snowboarding,
        WorkoutTypeEnum.snowSports.rawValue: .snowSports,
        WorkoutTypeEnum.soccer.rawValue: .soccer,
        WorkoutTypeEnum.softball.rawValue: .softball,
        WorkoutTypeEnum.squash.rawValue: .squash,
        WorkoutTypeEnum.stairClimbing.rawValue: .stairClimbing,
        WorkoutTypeEnum.stairs.rawValue: .stairs,
        WorkoutTypeEnum.stepTraining.rawValue: .stepTraining,
        WorkoutTypeEnum.surfingSports.rawValue: .surfingSports,
        WorkoutTypeEnum.swimming.rawValue: .swimming,
        WorkoutTypeEnum.tableTennis.rawValue: .tableTennis,
        WorkoutTypeEnum.taiChi.rawValue: .taiChi,
        WorkoutTypeEnum.tennis.rawValue: .tennis,
        WorkoutTypeEnum.trackAndField.rawValue: .trackAndField,
        WorkoutTypeEnum.traditionalStrengthTraining.rawValue: .traditionalStrengthTraining,
        WorkoutTypeEnum.volleyball.rawValue: .volleyball,
        WorkoutTypeEnum.walking.rawValue: .walking,
        WorkoutTypeEnum.waterFitness.rawValue: .waterFitness,
        WorkoutTypeEnum.waterPolo.rawValue: .waterPolo,
        WorkoutTypeEnum.waterSports.rawValue: .waterSports,
        WorkoutTypeEnum.wheelchairRunPace.rawValue: .wheelchairRunPace,
        WorkoutTypeEnum.wheelchairWalkPace.rawValue: .wheelchairWalkPace,
        WorkoutTypeEnum.wrestling.rawValue: .wrestling,
        WorkoutTypeEnum.yoga.rawValue: .yoga
    ]
    
    // Some of the workout types we support aren't listed here because the distance attribute doesn't apply to them,
    // or because they use a different unit type than "meters", which is the only one we support.
    // Otherwise, distance wouldn't be returned correctly.
    var workoutQuantityTypeIdentifierMap: [HKWorkoutActivityType: HKQuantityTypeIdentifier] {
        var map: [HKWorkoutActivityType: HKQuantityTypeIdentifier] = [
            .americanFootball: .distanceWalkingRunning,
            .australianFootball: .distanceWalkingRunning,
            .badminton: .distanceWalkingRunning,
            .baseball: .distanceWalkingRunning,
            .basketball: .distanceWalkingRunning,
            .cycling: .distanceCycling,
            .discSports: .distanceWalkingRunning,
            .golf: .distanceWalkingRunning,
            .handball: .distanceWalkingRunning,
            .hiking: .distanceWalkingRunning,
            .hockey: .distanceWalkingRunning,
            .lacrosse: .distanceWalkingRunning,
            .racquetball: .distanceWalkingRunning,
            .rugby: .distanceWalkingRunning,
            .running: .distanceWalkingRunning,
            .snowboarding: .distanceDownhillSnowSports,
            .soccer: .distanceWalkingRunning,
            .softball: .distanceWalkingRunning,
            .squash: .distanceWalkingRunning,
            .stairClimbing: .distanceWalkingRunning,
            .stairs: .distanceWalkingRunning,
            .swimming: .distanceSwimming,
            .tableTennis: .distanceWalkingRunning,
            .tennis: .distanceWalkingRunning,
            .trackAndField: .distanceWalkingRunning,
            .volleyball: .distanceWalkingRunning,
            .walking: .distanceWalkingRunning,
            .wheelchairRunPace: .distanceWheelchair,
            .wheelchairWalkPace: .distanceWheelchair,
            .downhillSkiing: .distanceDownhillSnowSports,
            .bowling: .distanceWalkingRunning,
            .boxing: .distanceWalkingRunning,
            .crossTraining: .distanceWalkingRunning,
            .fencing: .distanceWalkingRunning,
            .hunting: .distanceWalkingRunning,
            .jumpRope: .distanceWalkingRunning,
            .mixedCardio: .distanceWalkingRunning,
            .play: .distanceWalkingRunning,
            .stepTraining: .distanceWalkingRunning,
            .sailing: .distanceWalkingRunning,
            .snowSports: .distanceDownhillSnowSports,
            .surfingSports: .distanceWalkingRunning,
            .waterFitness: .distanceSwimming,
            .waterPolo: .distanceSwimming,
            .waterSports: .distanceSwimming
        ]
        
        if #available(iOS 18.0, *) {
            map[.rowing] = .distanceRowing
            map[.crossCountrySkiing] = .distanceCrossCountrySkiing
            map[.skatingSports] = .distanceSkatingSports
            map[.paddleSports] = .distancePaddleSports
        }
        
        return map
    }
    
    func distanceTypeIdentifier(for activityType: HKWorkoutActivityType) -> HKQuantityTypeIdentifier? {
        return self.workoutQuantityTypeIdentifierMap[activityType]
    }
}
