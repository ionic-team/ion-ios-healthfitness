import NotificationCenter

protocol NotificationManagerProtocol {
    func setDelegate(delegate: UNUserNotificationCenterDelegate)
    func addRequest(request: UNNotificationRequest, withCompletionHandler: ((Error?) -> Void)?)
    func setNotificationCategories(categories: Set<UNNotificationCategory>)
    func requestAuthorization(completion: @escaping  (Bool) -> Void)
}
