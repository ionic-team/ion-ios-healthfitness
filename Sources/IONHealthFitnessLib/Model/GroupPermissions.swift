import Foundation

class GroupPermissions: Codable {
    let isActive: Bool
    let accessType: String
    
    enum CodingKeys: String, CodingKey {
        case isActive = "IsActive"
        case accessType = "AccessType"
    }

    init(isActive: Bool, accessType: String) {
        self.isActive = isActive
        self.accessType = accessType
    }
    
}
