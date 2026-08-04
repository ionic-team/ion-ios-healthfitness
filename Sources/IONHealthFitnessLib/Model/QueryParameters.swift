public class AdvancedQueryParameters: Codable {
    public let variable: String?
    public let startDate, endDate: String?
    public let timeUnit, operationType: String?
    public let timeUnitLength: Int?
    public let advancedQueryReturnType: String?
    public let advancedQueryResultType: String?
    
    enum CodingKeys: String, CodingKey {
        case variable = "Variable"
        case startDate = "StartDate"
        case endDate = "EndDate"
        case timeUnit = "TimeUnit"
        case operationType = "OperationType"
        case timeUnitLength = "TimeUnitLength"
        case advancedQueryReturnType = "AdvancedQueryReturnType"
        case advancedQueryResultType = "AdvancedQueryResultType"
    }
    
    init(variable: String?, startDate: String?, endDate: String?, timeUnit: String?, operationType: String?, timeUnitLength: Int?, advancedQueryReturnType: String?, advancedQueryResultType: String?) {
        self.variable = variable
        self.startDate = startDate
        self.endDate = endDate
        self.timeUnit = timeUnit
        self.operationType = operationType
        self.timeUnitLength = timeUnitLength
        self.advancedQueryReturnType = advancedQueryReturnType
        self.advancedQueryResultType = advancedQueryResultType
    }
}

public class WorkoutAdvancedQueryParameters: Codable {
    public let workoutTypeVariables: [WorkoutTypeVariableMapping]
    public let startDate: String?
    public let endDate: String?
    
    enum CodingKeys: String, CodingKey {
        case workoutTypeVariables = "WorkoutTypeVariables"
        case startDate = "StartDate"
        case endDate = "EndDate"
    }
    
    init(workoutTypeVariables: [WorkoutTypeVariableMapping], startDate: String?, endDate: String?) {
        self.workoutTypeVariables = workoutTypeVariables
        self.startDate = startDate
        self.endDate = endDate
    }
}

public typealias WorkoutTypeVariableDictionary = [WorkoutType: VariableType]

public extension WorkoutAdvancedQueryParameters {
    var workoutTypeVariableDictionary: WorkoutTypeVariableDictionary {
        guard !self.workoutTypeVariables.isEmpty else { return [.all: .base] }
        return self.workoutTypeVariables.reduce(WorkoutTypeVariableDictionary()) { partialResult, map in
            var result = partialResult
            
            if let workoutType = WorkoutType.getWorkoutType(for: map.workoutType), !result.keys.contains(workoutType) {
                let variableTypeArray = map.variables.compactMap(VariableType.getVariableType(for:))
                let variableType = !variableTypeArray.isEmpty ? variableTypeArray.reduce(VariableType(), { $0.union($1) }) : .base
                
                result[workoutType] = variableType
            }
            
            return result
        }
    }
}

public class WorkoutTypeVariableMapping: Codable {
    public let workoutType: String
    public let variables: [String]
    
    enum CodingKeys: String, CodingKey {
        case workoutType = "WorkoutType"
        case variables = "VariableList"
    }
    
    init(workoutType: String, variables: [String]) {
        self.workoutType = workoutType
        self.variables = variables
    }
}
