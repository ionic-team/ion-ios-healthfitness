import NotificationCenter
@testable import IONHealthFitnessLib

class StubNotificationManager: NotificationManagerProtocol {
    
    var authorizationRequested = false
    var didAddRequest = false
    var didSetCategories = false
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        authorizationRequested = true
    }
    
    func setDelegate(delegate: UNUserNotificationCenterDelegate) {
        print("Nothing to do here.")
    }
    
    func addRequest(request: UNNotificationRequest, withCompletionHandler: ((Error?) -> Void)?) {
        didAddRequest = true
    }
    
    func setNotificationCategories(categories: Set<UNNotificationCategory>) {
        didSetCategories = true
    }
}
