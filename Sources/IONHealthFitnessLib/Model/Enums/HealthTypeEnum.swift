import Foundation

// MARK: - HealthTypeEnum
enum HealthTypeEnum: String {
    case stepCount = "STEPS"
    case heartRate = "HEART_RATE"
    case weight = "WEIGHT"
    case height = "HEIGHT"
    case bloodGlucose = "BLOOD_GLUCOSE"
    case bloodPressure = "BLOOD_PRESSURE"
    case sleepAnalysis = "SLEEP"
    case oxygenSaturation = "OXYGEN_SATURATION"
    case activeEnergyBurned = "CALORIES_BURNED"
    case bodyFatPercentage = "BODY_FAT_PERCENTAGE"
    case basalEnergyBurned = "BASAL_METABOLIC_RATE"
    case bodyTemperature = "BODY_TEMPERATURE"
    case dietaryWater = "HYDRATION"
    case dietaryEnergyConsumed = "NUTRITION"
    case pushCount = "PUSH_COUNT"
    case vo2max = "VO2MAX"
    case distance = "DISTANCE"
    case walkingSpeed = "WALKING_SPEED"
    
    case workout = "WORKOUT"
        
}

// MARK: - WorkoutTypeEnum
public enum WorkoutTypeEnum: String {
    case americanFootball = "AMERICAN_FOOTBALL"
    case archery = "ARCHERY"
    case australianFootball = "AUSTRALIAN_FOOTBALL"
    case badminton = "BADMINTON"
    case barre = "BARRE"
    case baseball = "BASEBALL"
    case basketball = "BASKETBALL"
    case bowling = "BOWLING"
    case boxing = "BOXING"
    case climbing = "CLIMBING"
    case coreTraining = "CORE_TRAINING"
    case crossCountrySkiing = "CROSS_COUNTRY_SKIING"
    case crossTraining = "CROSS_TRAINING"
    case curling = "CURLING"
    case cycling = "CYCLING"
    case dance = "DANCE"
    case danceInspiredTraining = "DANCE_INSPIRED_TRAINING"
    case discSports = "DISC_SPORTS"
    case downhillSkiing = "DOWNHILL_SKIING"
    case elliptical = "ELLIPTICAL"
    case equestrianSports = "EQUESTRIAN_SPORTS"
    case fencing = "FENCING"
    case fitnessGaming = "FITNESS_GAMING"
    case fishing = "FISHING"
    case flexibility = "FLEXIBILITY"
    case functionalStrengthTraining = "FUNCTIONAL_STRENGTH_TRAINING"
    case golf = "GOLF"
    case gymnastics = "GYMNASTICS"
    case handball = "HANDBALL"
    case handCycling = "HAND_CYCLING"
    case highIntensityIntervalTraining = "HIGH_INTENSITY_INTERVAL_TRAINING"
    case hiking = "HIKING"
    case hockey = "HOCKEY"
    case hunting = "HUNTING"
    case jumpRope = "JUMP_ROPE"
    case kickboxing = "KICKBOXING"
    case lacrosse = "LACROSSE"
    case martialArts = "MARTIAL_ARTS"
    case mindAndBody = "MIND_AND_BODY"
    case mixedCardio = "MIXED_CARDIO"
    case paddleSports = "PADDLE_SPORTS"
    case pilates = "PILATES"
    case play = "PLAY"
    case preparationAndRecovery = "PREPARATION_AND_RECOVERY"
    case racquetball = "RACQUETBALL"
    case rowing = "ROWING"
    case rugby = "RUGBY"
    case running = "RUNNING"
    case sailing = "SAILING"
    case skatingSports = "SKATING_SPORTS"
    case snowboarding = "SNOWBOARDING"
    case snowSports = "SNOW_SPORTS"
    case soccer = "SOCCER"
    case softball = "SOFTBALL"
    case squash = "SQUASH"
    case stairClimbing = "STAIR_CLIMBING"
    case stairs = "STAIRS"
    case stepTraining = "STEP_TRANING"
    case surfingSports = "SURFING_SPORTS"
    case swimming = "SWIMMING"
    case tableTennis = "TABLE_TENNIS"
    case taiChi = "TAI_CHI"
    case tennis = "TENNIS"
    case trackAndField = "TRACK_AND_FIELD"
    case traditionalStrengthTraining = "TRADITIONAL_STRENGTH_TRAINING"
    case volleyball = "VOLLEYBALL"
    case walking = "WALKING"
    case waterFitness = "WATER_FITNESS"
    case waterPolo = "WATER_POLO"
    case waterSports = "WATER_SPORTS"
    case wheelchairRunPace = "WHEELCHAIR_RUN_PACE"
    case wheelchairWalkPace = "WHEELCHAIR_WALK_PACE"
    case wrestling = "WRESTLING"
    case yoga = "YOGA"
}

// MARK: - AccessType
struct AccessType: OptionSet {
    let rawValue: Int
    
    static let read = Self(rawValue: 1 << 0)
    static let write = Self(rawValue: 1 << 1)
    static let readWrite: AccessType = [.read, .write]
}

extension AccessType: CustomStringConvertible {
    fileprivate struct Description {
        static let read = "READ"
        static let write = "WRITE"
        static let readWrite = "READWRITE"
    }
    
    var description: String {
        switch self {
        case .write:
            return Description.write
        case .readWrite:
            return Description.readWrite
        default:
            return Description.read
        }
    }
}

extension AccessType {
    static func getAccessType(for description: String) -> AccessType {
        let result: AccessType
        
        switch description {
        case Description.write:
            result = .write
        case Description.readWrite:
            result = .readWrite
        default:
            result = .read
        }
        
        return result
    }
}

// MARK: - VariableType
public struct VariableType: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let stepCount = Self(rawValue: 1 << 0)
    static let heartRate = Self(rawValue: 1 << 1)
    static let weight = Self(rawValue: 1 << 2)
    static let height = Self(rawValue: 1 << 3)
    static let bloodGlucose = Self(rawValue: 1 << 4)
    static let bloodPressure = Self(rawValue: 1 << 5)
    static let sleepAnalysis = Self(rawValue: 1 << 6)
    static let oxygenSaturation = Self(rawValue: 1 << 7)
    static let activeEnergyBurned = Self(rawValue: 1 << 8)
    static let bodyFatPercentage = Self(rawValue: 1 << 9)
    static let basalEnergyBurned = Self(rawValue: 1 << 10)
    static let bodyTemperature = Self(rawValue: 1 << 11)
    static let dietaryWater = Self(rawValue: 1 << 12)
    static let dietaryEnergyConsumed = Self(rawValue: 1 << 13)
    static let pushCount = Self(rawValue: 1 << 14)
    static let vo2max = Self(rawValue: 1 << 15)
    static let distance = Self(rawValue: 1 << 16)
    static let walkingSpeed = Self(rawValue: 1 << 17)
    
    static let base: VariableType = [.activeEnergyBurned, .heartRate]
}

extension VariableType {
    // swiftlint:disable cyclomatic_complexity
    public static func getVariableType(for description: String) -> VariableType? {
        var result: VariableType?
        
        switch description {
        case HealthTypeEnum.stepCount.rawValue: result = .stepCount
        case HealthTypeEnum.heartRate.rawValue: result = .heartRate
        case HealthTypeEnum.weight.rawValue: result = .weight
        case HealthTypeEnum.height.rawValue: result = .height
        case HealthTypeEnum.bloodGlucose.rawValue: result = .bloodGlucose
        case HealthTypeEnum.bloodPressure.rawValue: result = .bloodPressure
        case HealthTypeEnum.sleepAnalysis.rawValue: result = .sleepAnalysis
        case HealthTypeEnum.oxygenSaturation.rawValue: result = .oxygenSaturation
        case HealthTypeEnum.activeEnergyBurned.rawValue: result = .activeEnergyBurned
        case HealthTypeEnum.bodyFatPercentage.rawValue: result = .bodyFatPercentage
        case HealthTypeEnum.basalEnergyBurned.rawValue: result = .basalEnergyBurned
        case HealthTypeEnum.bodyTemperature.rawValue: result = .bodyTemperature
        case HealthTypeEnum.dietaryWater.rawValue: result = .dietaryWater
        case HealthTypeEnum.dietaryEnergyConsumed.rawValue: result = .dietaryEnergyConsumed
        case HealthTypeEnum.pushCount.rawValue: result = .pushCount
        case HealthTypeEnum.vo2max.rawValue: result = .vo2max
        case HealthTypeEnum.distance.rawValue: result = .distance
        case HealthTypeEnum.walkingSpeed.rawValue: result = .walkingSpeed
        default: break
        }
        
        return result
    }
    
    func healthTypes() -> [HealthTypeEnum] {
        var result = [HealthTypeEnum]()
 
        if self.contains(.stepCount) { result += [.stepCount] }
        if self.contains(.heartRate) { result += [.heartRate] }
        if self.contains(.weight) { result += [.weight] }
        if self.contains(.height) { result += [.height] }
        if self.contains(.bloodGlucose) { result += [.bloodGlucose] }
        if self.contains(.bloodPressure) { result += [.bloodPressure] }
        if self.contains(.sleepAnalysis) { result += [.sleepAnalysis] }
        if self.contains(.oxygenSaturation) { result += [.oxygenSaturation] }
        if self.contains(.activeEnergyBurned) { result += [.activeEnergyBurned] }
        if self.contains(.bodyFatPercentage) { result += [.bodyFatPercentage] }
        if self.contains(.basalEnergyBurned) { result += [.basalEnergyBurned] }
        if self.contains(.bodyTemperature) { result += [.bodyTemperature] }
        if self.contains(.dietaryWater) { result += [.dietaryWater] }
        if self.contains(.dietaryEnergyConsumed) { result += [.dietaryEnergyConsumed] }
        if self.contains(.pushCount) { result += [.pushCount] }
        if self.contains(.vo2max) { result += [.vo2max] }
        if self.contains(.distance) { result += [.distance] }
        if self.contains(.walkingSpeed) { result += [.walkingSpeed] }
        
        return result
    }
}

// MARK: - WorkoutType
public struct WorkoutType: OptionSet, Hashable {
    public let rawValue: UInt128
    
    public init(rawValue: UInt128) {
        self.rawValue = rawValue
    }
    
    static let americanFootball = Self(rawValue: 1 << 0)
    static let archery = Self(rawValue: 1 << 1)
    static let australianFootball = Self(rawValue: 1 << 2)
    static let badminton = Self(rawValue: 1 << 3)
    static let barre = Self(rawValue: 1 << 4)
    static let baseball = Self(rawValue: 1 << 5)
    static let basketball = Self(rawValue: 1 << 6)
    static let bowling = Self(rawValue: 1 << 7)
    static let boxing = Self(rawValue: 1 << 8)
    static let climbing = Self(rawValue: 1 << 9)
    static let coreTraining = Self(rawValue: 1 << 10)
    static let crossCountrySkiing = Self(rawValue: 1 << 11)
    static let crossTraining = Self(rawValue: 1 << 12)
    static let curling = Self(rawValue: 1 << 13)
    static let cycling = Self(rawValue: 1 << 14)
    static let dance = Self(rawValue: 1 << 15)
    static let danceInspiredTraining = Self(rawValue: 1 << 16)
    static let discSports = Self(rawValue: 1 << 17)
    static let downhillSkiing = Self(rawValue: 1 << 18)
    static let elliptical = Self(rawValue: 1 << 19)
    static let equestrianSports = Self(rawValue: 1 << 20)
    static let fencing = Self(rawValue: 1 << 21)
    static let fitnessGaming = Self(rawValue: 1 << 22)
    static let fishing = Self(rawValue: 1 << 23)
    static let flexibility = Self(rawValue: 1 << 24)
    static let functionalStrengthTraining = Self(rawValue: 1 << 25)
    static let golf = Self(rawValue: 1 << 26)
    static let gymnastics = Self(rawValue: 1 << 27)
    static let handball = Self(rawValue: 1 << 28)
    static let handCycling = Self(rawValue: 1 << 29)
    static let highIntensityIntervalTraining = Self(rawValue: 1 << 30)
    static let hiking = Self(rawValue: 1 << 31)
    static let hockey = Self(rawValue: 1 << 32)
    static let hunting = Self(rawValue: 1 << 33)
    static let jumpRope = Self(rawValue: 1 << 34)
    static let kickboxing = Self(rawValue: 1 << 35)
    static let lacrosse = Self(rawValue: 1 << 36)
    static let martialArts = Self(rawValue: 1 << 37)
    static let mindAndBody = Self(rawValue: 1 << 38)
    static let mixedCardio = Self(rawValue: 1 << 39)
    static let paddleSports = Self(rawValue: 1 << 40)
    static let pilates = Self(rawValue: 1 << 41)
    static let play = Self(rawValue: 1 << 42)
    static let preparationAndRecovery = Self(rawValue: 1 << 43)
    static let racquetball = Self(rawValue: 1 << 44)
    static let rowing = Self(rawValue: 1 << 45)
    static let rugby = Self(rawValue: 1 << 46)
    static let running = Self(rawValue: 1 << 47)
    static let sailing = Self(rawValue: 1 << 48)
    static let skatingSports = Self(rawValue: 1 << 49)
    static let snowboarding = Self(rawValue: 1 << 50)
    static let snowSports = Self(rawValue: 1 << 51)
    static let soccer = Self(rawValue: 1 << 52)
    static let softball = Self(rawValue: 1 << 53)
    static let squash = Self(rawValue: 1 << 54)
    static let stairClimbing = Self(rawValue: 1 << 55)
    static let stairs = Self(rawValue: 1 << 56)
    static let stepTraining = Self(rawValue: 1 << 57)
    static let surfingSports = Self(rawValue: 1 << 58)
    static let swimming = Self(rawValue: 1 << 59)
    static let tableTennis = Self(rawValue: 1 << 60)
    static let taiChi = Self(rawValue: 1 << 61)
    static let tennis = Self(rawValue: 1 << 62)
    static let trackAndField = Self(rawValue: 1 << 63)
    static let traditionalStrengthTraining = Self(rawValue: 1 << 64)
    static let volleyball = Self(rawValue: 1 << 65)
    static let walking = Self(rawValue: 1 << 66)
    static let waterFitness = Self(rawValue: 1 << 67)
    static let waterPolo = Self(rawValue: 1 << 68)
    static let waterSports = Self(rawValue: 1 << 69)
    static let wheelchairRunPace = Self(rawValue: 1 << 70)
    static let wheelchairWalkPace = Self(rawValue: 1 << 71)
    static let wrestling = Self(rawValue: 1 << 72)
    static let yoga = Self(rawValue: 1 << 73)
    
    static let all: WorkoutType = [
        .americanFootball,
        .archery,
        .australianFootball,
        .badminton,
        .barre,
        .baseball,
        .basketball,
        .bowling,
        .boxing,
        .climbing,
        .coreTraining,
        .crossCountrySkiing,
        .crossTraining,
        .curling,
        .cycling,
        .dance,
        .danceInspiredTraining,
        .discSports,
        .downhillSkiing,
        .elliptical,
        .equestrianSports,
        .fencing,
        .fitnessGaming,
        .fishing,
        .flexibility,
        .functionalStrengthTraining,
        .golf,
        .gymnastics,
        .handball,
        .handCycling,
        .highIntensityIntervalTraining,
        .hiking,
        .hockey,
        .hunting,
        .jumpRope,
        .kickboxing,
        .lacrosse,
        .martialArts,
        .mindAndBody,
        .mixedCardio,
        .paddleSports,
        .pilates,
        .play,
        .preparationAndRecovery,
        .racquetball,
        .rowing,
        .rugby,
        .running,
        .sailing,
        .skatingSports,
        .snowboarding,
        .snowSports,
        .soccer,
        .softball,
        .squash,
        .stairClimbing,
        .stairs,
        .stepTraining,
        .surfingSports,
        .swimming,
        .tableTennis,
        .taiChi,
        .tennis,
        .trackAndField,
        .traditionalStrengthTraining,
        .volleyball,
        .walking,
        .waterFitness,
        .waterPolo,
        .waterSports,
        .wheelchairRunPace,
        .wheelchairWalkPace,
        .wrestling,
        .yoga
    ]
}

extension WorkoutType {
    public static func getWorkoutType(for description: String) -> WorkoutType? {
        var result: WorkoutType?
        
        switch description {
        case WorkoutTypeEnum.americanFootball.rawValue: result = .americanFootball
        case WorkoutTypeEnum.archery.rawValue: result = .archery
        case WorkoutTypeEnum.australianFootball.rawValue: result = .australianFootball
        case WorkoutTypeEnum.badminton.rawValue: result = .badminton
        case WorkoutTypeEnum.barre.rawValue: result = .barre
        case WorkoutTypeEnum.baseball.rawValue: result = .baseball
        case WorkoutTypeEnum.basketball.rawValue: result = .basketball
        case WorkoutTypeEnum.bowling.rawValue: result = .bowling
        case WorkoutTypeEnum.boxing.rawValue: result = .boxing
        case WorkoutTypeEnum.climbing.rawValue: result = .climbing
        case WorkoutTypeEnum.coreTraining.rawValue: result = .coreTraining
        case WorkoutTypeEnum.crossCountrySkiing.rawValue: result = .crossCountrySkiing
        case WorkoutTypeEnum.crossTraining.rawValue: result = .crossTraining
        case WorkoutTypeEnum.curling.rawValue: result = .curling
        case WorkoutTypeEnum.cycling.rawValue: result = .cycling
        case WorkoutTypeEnum.dance.rawValue: result = .dance
        case WorkoutTypeEnum.danceInspiredTraining.rawValue: result = .danceInspiredTraining
        case WorkoutTypeEnum.discSports.rawValue: result = .discSports
        case WorkoutTypeEnum.downhillSkiing.rawValue: result = .downhillSkiing
        case WorkoutTypeEnum.elliptical.rawValue: result = .elliptical
        case WorkoutTypeEnum.equestrianSports.rawValue: result = .equestrianSports
        case WorkoutTypeEnum.fencing.rawValue: result = .fencing
        case WorkoutTypeEnum.fitnessGaming.rawValue: result = .fitnessGaming
        case WorkoutTypeEnum.fishing.rawValue: result = .fishing
        case WorkoutTypeEnum.flexibility.rawValue: result = .flexibility
        case WorkoutTypeEnum.functionalStrengthTraining.rawValue: result = .functionalStrengthTraining
        case WorkoutTypeEnum.golf.rawValue: result = .golf
        case WorkoutTypeEnum.gymnastics.rawValue: result = .gymnastics
        case WorkoutTypeEnum.handball.rawValue: result = .handball
        case WorkoutTypeEnum.handCycling.rawValue: result = .handCycling
        case WorkoutTypeEnum.highIntensityIntervalTraining.rawValue: result = .highIntensityIntervalTraining
        case WorkoutTypeEnum.hiking.rawValue: result = .hiking
        case WorkoutTypeEnum.hockey.rawValue: result = .hockey
        case WorkoutTypeEnum.hunting.rawValue: result = .hunting
        case WorkoutTypeEnum.jumpRope.rawValue: result = .jumpRope
        case WorkoutTypeEnum.kickboxing.rawValue: result = .kickboxing
        case WorkoutTypeEnum.lacrosse.rawValue: result = .lacrosse
        case WorkoutTypeEnum.martialArts.rawValue: result = .martialArts
        case WorkoutTypeEnum.mindAndBody.rawValue: result = .mindAndBody
        case WorkoutTypeEnum.mixedCardio.rawValue: result = .mixedCardio
        case WorkoutTypeEnum.paddleSports.rawValue: result = .paddleSports
        case WorkoutTypeEnum.pilates.rawValue: result = .pilates
        case WorkoutTypeEnum.play.rawValue: result = .play
        case WorkoutTypeEnum.preparationAndRecovery.rawValue: result = .preparationAndRecovery
        case WorkoutTypeEnum.racquetball.rawValue: result = .racquetball
        case WorkoutTypeEnum.rowing.rawValue: result = .rowing
        case WorkoutTypeEnum.rugby.rawValue: result = .rugby
        case WorkoutTypeEnum.running.rawValue: result = .running
        case WorkoutTypeEnum.sailing.rawValue: result = .sailing
        case WorkoutTypeEnum.skatingSports.rawValue: result = .skatingSports
        case WorkoutTypeEnum.snowboarding.rawValue: result = .snowboarding
        case WorkoutTypeEnum.snowSports.rawValue: result = .snowSports
        case WorkoutTypeEnum.soccer.rawValue: result = .soccer
        case WorkoutTypeEnum.softball.rawValue: result = .softball
        case WorkoutTypeEnum.squash.rawValue: result = .squash
        case WorkoutTypeEnum.stairClimbing.rawValue: result = .stairClimbing
        case WorkoutTypeEnum.stairs.rawValue: result = .stairs
        case WorkoutTypeEnum.stepTraining.rawValue: result = .stepTraining
        case WorkoutTypeEnum.surfingSports.rawValue: result = .surfingSports
        case WorkoutTypeEnum.swimming.rawValue: result = .swimming
        case WorkoutTypeEnum.tableTennis.rawValue: result = .tableTennis
        case WorkoutTypeEnum.taiChi.rawValue: result = .taiChi
        case WorkoutTypeEnum.tennis.rawValue: result = .tennis
        case WorkoutTypeEnum.trackAndField.rawValue: result = .trackAndField
        case WorkoutTypeEnum.traditionalStrengthTraining.rawValue: result = .traditionalStrengthTraining
        case WorkoutTypeEnum.volleyball.rawValue: result = .volleyball
        case WorkoutTypeEnum.walking.rawValue: result = .walking
        case WorkoutTypeEnum.waterFitness.rawValue: result = .waterFitness
        case WorkoutTypeEnum.waterPolo.rawValue: result = .waterPolo
        case WorkoutTypeEnum.waterSports.rawValue: result = .waterSports
        case WorkoutTypeEnum.wheelchairRunPace.rawValue: result = .wheelchairRunPace
        case WorkoutTypeEnum.wheelchairWalkPace.rawValue: result = .wheelchairWalkPace
        case WorkoutTypeEnum.wrestling.rawValue: result = .wrestling
        case WorkoutTypeEnum.yoga.rawValue: result = .yoga
        default: break
        }
        
        return result
    }
    
    func workoutTypeEnums() -> [WorkoutTypeEnum] {
        var result = [WorkoutTypeEnum]()
        
        if self.contains(.americanFootball) { result += [.americanFootball] }
        if self.contains(.archery) { result += [.archery] }
        if self.contains(.australianFootball) { result += [.australianFootball] }
        if self.contains(.badminton) { result += [.badminton] }
        if self.contains(.barre) { result += [.barre] }
        if self.contains(.baseball) { result += [.baseball] }
        if self.contains(.basketball) { result += [.basketball] }
        if self.contains(.bowling) { result += [.bowling] }
        if self.contains(.boxing) { result += [.boxing] }
        if self.contains(.climbing) { result += [.climbing] }
        if self.contains(.coreTraining) { result += [.coreTraining] }
        if self.contains(.crossCountrySkiing) { result += [.crossCountrySkiing] }
        if self.contains(.crossTraining) { result += [.crossTraining] }
        if self.contains(.curling) { result += [.curling] }
        if self.contains(.cycling) { result += [.cycling] }
        if self.contains(.dance) { result += [.dance] }
        if self.contains(.danceInspiredTraining) { result += [.danceInspiredTraining] }
        if self.contains(.discSports) { result += [.discSports] }
        if self.contains(.downhillSkiing) { result += [.downhillSkiing] }
        if self.contains(.elliptical) { result += [.elliptical] }
        if self.contains(.equestrianSports) { result += [.equestrianSports] }
        if self.contains(.fencing) { result += [.fencing] }
        if self.contains(.fitnessGaming) { result += [.fitnessGaming] }
        if self.contains(.fishing) { result += [.fishing] }
        if self.contains(.flexibility) { result += [.flexibility] }
        if self.contains(.functionalStrengthTraining) { result += [.functionalStrengthTraining] }
        if self.contains(.golf) { result += [.golf] }
        if self.contains(.gymnastics) { result += [.gymnastics] }
        if self.contains(.handball) { result += [.handball] }
        if self.contains(.handCycling) { result += [.handCycling] }
        if self.contains(.highIntensityIntervalTraining) { result += [.highIntensityIntervalTraining] }
        if self.contains(.hiking) { result += [.hiking] }
        if self.contains(.hockey) { result += [.hockey] }
        if self.contains(.hunting) { result += [.hunting] }
        if self.contains(.jumpRope) { result += [.jumpRope] }
        if self.contains(.kickboxing) { result += [.kickboxing] }
        if self.contains(.lacrosse) { result += [.lacrosse] }
        if self.contains(.martialArts) { result += [.martialArts] }
        if self.contains(.mindAndBody) { result += [.mindAndBody] }
        if self.contains(.mixedCardio) { result += [.mixedCardio] }
        if self.contains(.paddleSports) { result += [.paddleSports] }
        if self.contains(.pilates) { result += [.pilates] }
        if self.contains(.play) { result += [.play] }
        if self.contains(.preparationAndRecovery) { result += [.preparationAndRecovery] }
        if self.contains(.racquetball) { result += [.racquetball] }
        if self.contains(.rowing) { result += [.rowing] }
        if self.contains(.rugby) { result += [.rugby] }
        if self.contains(.running) { result += [.running] }
        if self.contains(.sailing) { result += [.sailing] }
        if self.contains(.skatingSports) { result += [.skatingSports] }
        if self.contains(.snowboarding) { result += [.snowboarding] }
        if self.contains(.snowSports) { result += [.snowSports] }
        if self.contains(.soccer) { result += [.soccer] }
        if self.contains(.softball) { result += [.softball] }
        if self.contains(.squash) { result += [.squash] }
        if self.contains(.stairClimbing) { result += [.stairClimbing] }
        if self.contains(.stairs) { result += [.stairs] }
        if self.contains(.stepTraining) { result += [.stepTraining] }
        if self.contains(.surfingSports) { result += [.surfingSports] }
        if self.contains(.swimming) { result += [.swimming] }
        if self.contains(.tableTennis) { result += [.tableTennis] }
        if self.contains(.taiChi) { result += [.taiChi] }
        if self.contains(.tennis) { result += [.tennis] }
        if self.contains(.trackAndField) { result += [.trackAndField] }
        if self.contains(.traditionalStrengthTraining) { result += [.traditionalStrengthTraining] }
        if self.contains(.volleyball) { result += [.volleyball] }
        if self.contains(.walking) { result += [.walking] }
        if self.contains(.waterFitness) { result += [.waterFitness] }
        if self.contains(.waterPolo) { result += [.waterPolo] }
        if self.contains(.waterSports) { result += [.waterSports] }
        if self.contains(.wheelchairRunPace) { result += [.wheelchairRunPace] }
        if self.contains(.wheelchairWalkPace) { result += [.wheelchairWalkPace] }
        if self.contains(.wrestling) { result += [.wrestling] }
        if self.contains(.yoga) { result += [.yoga] }
        
        return result
    }
    // swiftlint:enable cyclomatic_complexity
}
