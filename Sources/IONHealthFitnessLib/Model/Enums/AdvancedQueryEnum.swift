// MARK: - AdvancedQueryReturnTypeEnum
public enum AdvancedQueryReturnTypeEnum: String {
    case allData = "ALL_DATA"
    case removeEmptyDataBlocks = "REMOVE_EMPTY_BLOCKS"
}

// MARK: - AdvancedQueryResultType
public struct AdvancedQueryResultType: OptionSet {
    public typealias RawValue = Int
    
    public var rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public static let rawDataType = Self(rawValue: 1 << 0)
    public static let dataPointType = Self(rawValue: 1 << 1)
    public static let allType: AdvancedQueryResultType = [.rawDataType, .dataPointType]
}

extension AdvancedQueryResultType {
    private struct Description {
        static let rawDataType = "RAW_DATA"
        static let dataPointType = "DATA_POINT"
        static let allType = "ALL_DATA"
    }
    
    public static func get(with description: String) -> AdvancedQueryResultType {
        let result: AdvancedQueryResultType
        
        switch description {
        case Description.rawDataType:
            result = .rawDataType
        case Description.dataPointType:
            result = .dataPointType
        default:
            result = .allType
        }
        
        return result
    }
}
