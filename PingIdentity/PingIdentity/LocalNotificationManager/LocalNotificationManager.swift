//
//  LocalNotificationManager.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation
import UserNotifications

// MARK: - LocalNotificationManager Class

class LocalNotificationManager{
    
    // MARK: - Notification Permission
    
    /// Requests permission for local notifications with specified options.
    ///
    /// - Note: This method should be called to request user permission for notifications.
    static func askForNotificationPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge , .sound, .alert]) {  (granted , error) in
            if error == nil {
                print("Notificarion Granted")
            }
        }
    }
    
    // MARK: - Send Local Push Notification
    
    /// Constructs and sends a local push notification with the given payload.
    ///
    /// - Parameter payload: The payload data to be included in the notification.
    ///
    /// - Note: This method creates a local notification with the specified payload and schedules it for delivery.
    static func sendLocalPushNotification(payload: [String : Any] , delay : TimeInterval) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = StringConstants.Notification.TitleText
        content.body = StringConstants.Notification.BodyText
        content.sound = UNNotificationSound.default
        content.userInfo = [StringConstants.JSONKey.Payload: payload]
        
        // Create notification trigger (15 second delay, non-repeating)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        
        // Generate a unique identifier for the notification request
        let uuid = UUID().uuidString
        
        // Create notification request
        let request = UNNotificationRequest(identifier: uuid , content: content, trigger: trigger)
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling local push notification: \(error)")
            }
        }
    }
}
