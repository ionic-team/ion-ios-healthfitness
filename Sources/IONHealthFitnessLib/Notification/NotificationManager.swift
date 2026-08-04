//
//  NotificationManager.swift
//  IONHealthFitnessLib
//
//  Created by Nelson Silva on 20/12/2021.
//

import Foundation
import NotificationCenter

class NotificationManager: NotificationManagerProtocol {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func setDelegate(delegate: UNUserNotificationCenterDelegate) {
        notificationCenter.delegate = delegate
    }
    
    func addRequest(request: UNNotificationRequest, withCompletionHandler: ((Error?) -> Void)?) {
        notificationCenter.add(request, withCompletionHandler: withCompletionHandler)
    }
    
    func setNotificationCategories(categories: Set<UNNotificationCategory>) {
        notificationCenter.setNotificationCategories(categories)
    }
    
    func requestAuthorization(completion: @escaping  (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
              completion(granted)
            }
    }
    
}
