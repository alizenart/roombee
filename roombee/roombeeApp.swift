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

    @State var demoIsSleeping: Bool = false
    @State var demoInRoom: Bool = false
    
    

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(authViewModel)
                .environmentObject(eventStore)
                .environmentObject(navManager)
                .environmentObject(selectedDate)
  //        ContentView().environmentObject(eventStore)
            if authManager.isAuthenticated {
                HomepageView(
                    demoIsSleeping: $demoIsSleeping,
                    demoInRoom: $demoInRoom
                )
                .environmentObject(eventStore)
                .environmentObject(authManager)
                .environmentObject(navManager)
                .environmentObject(apiManager)
                .onAppear {
                    fetchInitialToggleStates()
                }

            } else {
                SignUp()
                    .environmentObject(eventStore)
                    .environmentObject(authManager)
            }
        }
    }
    
    private func fetchInitialToggleStates() {
        apiManager.fetchToggles(userId: "80003") { toggles, error in
            if let toggles = toggles, let firstToggle = toggles.first {
                DispatchQueue.main.async {
                    demoIsSleeping = (firstToggle.isSleeping != 0)
                    demoInRoom = (firstToggle.inRoom != 0)
                }
            } else if let error = error {
                print("error fetching toggles: \(error)")
            }
        }
    }
}
