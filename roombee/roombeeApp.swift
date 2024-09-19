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


@MainActor
class AppDelegate: NSObject, UIApplicationDelegate {
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
        UIApplication.shared.registerForRemoteNotifications()
        return true
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


