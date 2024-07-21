//
//  Notifs.swift
//  roombee
//
//  Created by Nicole Liu on 5/27/24.
//

//ignore for now, this is for push notifs
import Foundation
import UIKit
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    static let shared = NotificationService()
    private var askPerm = false
    
    func requestPerm() {
        guard !askPerm else {return}
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print(error)
            } else if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                self.askPerm = true
            }
        }
    }
    
    func scheduleNotification(for event: CalendarEvent) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Event"
        content.body = "Your event \"\(event.title)\" is starting in 30 minutes."
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -30, to: event.startTimeCal)!
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
            
        }
    }
    
    func todoNotif() {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "You have tasks remaining!"
        content.sound = UNNotificationSound.default
        
        var date = DateComponents()
        date.hour = 18
        date.minute = 10
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "dailytodo", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func toggleSleep(isAsleep: Bool) {
        let content = UNMutableNotificationContent()
        content.title = isAsleep ? "😴" : "🌞"
        content.body = isAsleep ? "Your roommate is heading to bed!" : "Rise and Shine!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "toggleSleep", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error with sleep toggle: \(error)")
            }
        }
    }
    
    func toggleRoom(inRoom: Bool) {
        let content = UNMutableNotificationContent()
        content.title = inRoom ? "🏡" : "🧍"
        content.body = inRoom ? "Your roommate is back!" : "Room's all yours!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "toggleRoom", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error with sleep toggle: \(error)")
            }
        }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification:
                                UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        logContents(of: notification)
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        logContents(of: response.notification)
        completionHandler()
    }
    
    func logContents(of notifications: UNNotification) {
        print(notifications.request.content.userInfo)
    }
    
}
