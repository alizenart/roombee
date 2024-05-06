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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: ProcessInfo.processInfo.environment["ROOMBEE_ADWAIT_IAMUSER_ACCESSKEY"] ?? "", secretKey: ProcessInfo.processInfo.environment["ROOMBEE_ADWAIT_IAMUSER_SECRETKEY"] ?? "")
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        return true
    }
}

@main
struct roombeeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthenticationViewModel()
    @StateObject var navManager = NavManager()
    @StateObject var selectedDate = SelectedDateManager()
    var eventStore = EventStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(authViewModel)
                .environmentObject(EventStore())
                .environmentObject(navManager)
                .environmentObject(selectedDate)
        }
    }
}

