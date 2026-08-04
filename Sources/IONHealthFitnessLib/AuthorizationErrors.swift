import Foundation

typealias CompletionHandler = () throws -> HealthKitErrors?

public enum HealthKitErrors: Int, CustomNSError, LocalizedError {
    case variableNotAvailable = 100
    case variableNotAuthorized = 101
    case operationNotAllowed = 102
    case errorWhileReading = 103
    case errorWhileWriting = 104
    case variableHasWriteDenied = 105
    case badParameterType = 106
    case authorizationError = 107
    case notAvailableOnDevice = 108
    case unitNotAvailable = 109
    case backgroundJobAlreadyExists = 111
    case invalidBackgroundJobID = 113
    case backgroundJobNotFound = 114
    case unsubscribeError = 115
    
    case workoutTypeNotAvailable = 116
    case workoutTypeNotAuthorized = 117
    
    var description: String {
        switch self {
        case .notAvailableOnDevice:
            return "HealthKit not available on device."
        case .variableNotAvailable:
            return "Variable not available."
        case .variableHasWriteDenied:
            return "Variable has write denied."
        case .authorizationError:
            return "Authorization error."
        case .variableNotAuthorized:
            return "Variable not authorized."
        case .operationNotAllowed:
            return "Operation not allowed."
        case .badParameterType:
            return "Invalid parameter."
        case .errorWhileReading:
            return "Error while reading data."
        case .errorWhileWriting:
            return "Error while writing data."
        case .unitNotAvailable:
            return "Variable not available."
        case .backgroundJobAlreadyExists:
            return "The background job you are trying to set already exists."
        case .invalidBackgroundJobID:
            return "Invalid background Job ID."
        case .backgroundJobNotFound:
            return "The background job could not be found."
        case .unsubscribeError:
            return "The background job could not be deleted."
            
        case .workoutTypeNotAvailable:
            return "Workout Type not available."
        case .workoutTypeNotAuthorized:
            return "Workout Type not authorized."
        }
    }
    
    public var errorDescription: String? {
        return description.isEmpty ? NSLocalizedString(String(rawValue), comment: "") : description
    }
        
}
