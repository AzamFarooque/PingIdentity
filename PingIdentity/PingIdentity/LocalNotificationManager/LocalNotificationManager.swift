//
//  LocalNotificationManager.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation
import UserNotifications

class LocalNotificationManager{
    
    // MARK: - Notification permisssion
    
    static func askForNotificationPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge , .sound, .alert]) {  (granted , error) in
            if error == nil {
                print("Notificarion Granted")
            }
        }
    }
    
    // MARK: - Construct and send local notification
    
    static func sendLocalPushNotification(payload: [String : Any]) {
        let content = UNMutableNotificationContent()
        content.title = StringConstants.Notification.TitleText
        content.body = StringConstants.Notification.BodyText
        content.userInfo = [StringConstants.JSONKey.Payload: payload]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let uuid = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuid , content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling local push notification: \(error)")
            }
        }
    }
    
    
}
