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
    @StateObject var apiManager = APIManager()
    var eventStore = EventStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(authViewModel)
                .environmentObject(eventStore)
                .environmentObject(navManager)
                .environmentObject(selectedDate)
  //        ContentView().environmentObject(eventStore)
            if authManager.isAuthenticated {
                HomepageView()
                    .environmentObject(EventStore())
                    .environmentObject(authManager)
                    .environmentObject(navManager)
                    .environmentObject(apiManager)
                    .onAppear {
                        APIManager.shared.fetchToggles { toggles, error in
                            if let toggles = toggles {
                                print("got events from api call \(toggles)")
                            } else if let error = error {
                                print("error fetching toggles: \(error)")
                            }
                        }
                    }

            } else {
                SignUp()
                    .environmentObject(EventStore())
                    .environmentObject(authManager)
            }
            
        }
    }
}

