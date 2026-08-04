import HealthKit

struct HealthRecordSourceDevice: Encodable {
    let model: String?
    let manufacturer: String?
}

struct HealthRecordMetadata : Encodable {
    let recordingMethod: HealthRecordingMethod
    let device: HealthRecordSourceDevice?
    let originApp: String?
}

extension HKObject {
    func healthRecordMetadata() -> HealthRecordMetadata {
        let isUserEntered = metadata?[HKMetadataKeyWasUserEntered] as? Bool ?? false
        let method: HealthRecordingMethod = isUserEntered ? .manual : .automatic

        let deviceInfo: HealthRecordSourceDevice? = {
            guard let device = device else { return nil }
            return HealthRecordSourceDevice(model: device.model ?? device.name, manufacturer: device.manufacturer)
        }()

        return HealthRecordMetadata(recordingMethod: method, device: deviceInfo, originApp: sourceRevision.source.bundleIdentifier)
    }
}
