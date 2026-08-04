import Foundation

struct AdvancedQueryResponseBlock: Encodable {
    var block: Int?
    var startDate: Int?
    var endDate: Int?
    var values: [Double]?
    var additionalData: String?
    var recordMetadataList: [HealthRecordMetadata]? 
}

struct AdvancedQueryResponse: Encodable {
    var results: [AdvancedQueryResponseBlock]?
    var resultDataPoints: [AdvancedQueryDataPoint]?
}

struct WorkoutAdvancedQueryResponseBlock: Encodable {
    var activity: String?
    var startDate: Int?
    var endDate: Int?
    var duration: Double?
    var totalEnergyBurned: Double?
    var totalDistance: Double?
    var samples: [AdvancedQueryResponseBlock]?
    var recordMetadata: HealthRecordMetadata?
}

struct WorkoutAdvancedQueryResponse: Encodable {
    var results: [WorkoutAdvancedQueryResponseBlock]?
}

struct BackgroundJobsResponseBlock: Encodable {
    var variable: String?
    var condition: String?
    var value: Double?
    var notificationHeader: String?
    var notificationBody: String?
    var notificationFrequency: String?
    var notificationFrequencyGrouping: Int?
    var active: String?
    var id: String?
}

struct AdvancedQueryDataPoint: Encodable {
    var label: String
    var value: Double
    
    enum CodingKeys: String, CodingKey {
        case label = "Label", value = "Value"   // DataPoint is an OutsystemsCharts structure and we can't change its `name in json` property
    }
}

struct BackgroundJobsResponse: Encodable {
    var results: [BackgroundJobsResponseBlock]?
}

extension Collection {
    var toOptional: Self? {
        return isEmpty ? nil : self
    }
}
