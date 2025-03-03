//
//  roombeeApp.swift
//  roombee
//
//  Created by Adwait Ganguly on 10/7/23.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import AWSLambda
import AWSCore
import KeychainAccess
import Mixpanel
import UserNotifications
import FirebaseMessaging


@MainActor
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        let keychain = Keychain(service: "com.yourapp.roombee")
                
        if keychain["AWSAccessKey"] == nil || keychain["AWSSecretKey"] == nil {
            keychain["AWSAccessKey"] = "AKIAVRUVUAMKWI2RRWPK"
            keychain["AWSSecretKey"] = "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"
        }
        
        // Retrieve AWS credentials from Keychain
        guard let accessKey = keychain["AWSAccessKey"],
              let secretKey = keychain["AWSSecretKey"] else {
            print("Failed to retrieve AWS credentials from Keychain.")
            return false
        }
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        Mixpanel.initialize(token: "afcb925e6a6fc8b2cb699e8e0251aebb", trackAutomaticEvents: false)
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = self
                
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, _ in
                    guard success else {
                        return
                    }
                    UNUserNotificationCenter.current().delegate = self
                    Messaging.messaging().delegate = self
                }
                application.registerForRemoteNotifications()
        return true
    }
    
    // Handle device token registration
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            }
        func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("Failed to register for notifications: \(error.localizedDescription)")
        }
        
        nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([[.banner, .list, .sound]])
        }
        
        nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,  didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            let userInfo = response.notification.request.content.userInfo
            NotificationCenter.default.post(name: Notification.Name("didReceiveRemoteNotification"), object: nil, userInfo: userInfo)
            completionHandler()
        }
        
        @objc nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
            if let fcmToken = fcmToken {
                    print("Firebase token: \(fcmToken)")
                    DispatchQueue.main.async {
                        TokenManager.shared.fcmToken = fcmToken
                    }
                }
        }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print("in Roombee App")
        if let incomingURL = userActivity.webpageURL {
            print("Incoming URL: \(incomingURL)")
            handleIncomingURL(incomingURL)
            return true
        }
        return false
    }
    
    private func handleIncomingURL(_ url: URL) {
        if url.scheme == "roombee" {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems {
                for item in queryItems {
                    if item.name == "hive_code", let value = item.value {
                        NotificationCenter.default.post(name: .receivedHiveCode, object: nil, userInfo: ["hive_code": value])
                    }
                }
            }
        }
    }
    
}

@main
struct roombeeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthenticationViewModel()
    @StateObject var navManager = NavManager()
    @StateObject var selectedDate = SelectedDateManager()
    @StateObject var todoManager = TodoViewModel()
    @StateObject var agreementManager = RoommateAgreementHandler()
    @StateObject var agreementStore = RoommateAgreementStore()
    @StateObject var eventStore = EventStore()
    @StateObject var toggleManager = ToggleViewModel()

        
    //onboard Guide manager
    @StateObject var onboardGuideManager = OnboardGuideViewModel()
    
    @State private var inviteLink: String = ""
    @State private var showInviteLinkPopup: Bool = false
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(eventStore)
                .environmentObject(navManager)
                .environmentObject(selectedDate)
                .environmentObject(todoManager)
                .environmentObject(toggleManager)
                .environmentObject(agreementManager)
                .environmentObject(agreementStore)
                .environmentObject(onboardGuideManager)
                .environmentObject(agreementStore)
                .onReceive(NotificationCenter.default.publisher(for: .receivedHiveCode)) { notification in
                    if let userInfo = notification.userInfo,
                       let hiveCode = userInfo["hive_code"] as? String {
//                        authViewModel.skipCreateOrJoin = false
                        authViewModel.hive_code = hiveCode
                    }
                }
        }
    }
}

extension Notification.Name {
    static let receivedHiveCode = Notification.Name("receivedHiveCode")
}


