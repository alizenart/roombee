//
//  roombeeApp.swift
//  roombee
//
//  Created by Adwait Ganguly on 10/7/23.
//

import SwiftUI
import Amplify
import AWSDataStorePlugin
//import AWSCognitoAuthPlugin


@main

struct roombeeApp: App {
    @StateObject var authManager = AuthManager()

  var eventStore = EventStore()
  
  init() { // default init and configure
    print("hello???")

    configureAmplify()
  }
  
  var body: some Scene {
      WindowGroup {
//        ContentView().environmentObject(eventStore)
          if authManager.isAuthenticated {
              HomepageView(calGrid: GridView(cal: CalendarView(title: "Me"), cal2: CalendarView(title: "Roomate")), yourStatus: StatusView(title: "Me:"), roomStatus: StatusView(title: "Roommate:"))
                  .environmentObject(EventStore())
                  .environmentObject(authManager)

          } else {
              SignUp()
                  .environmentObject(eventStore)
                  .environmentObject(authManager)
          }
      }
  }
}

func configureAmplify() {
  let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
  do {
    try Amplify.add(plugin: dataStorePlugin)
    // try Amplify.add(plugin: AWSCognitoAuthPlugin()) // Add the Auth plugin

    try Amplify.configure()
    print("Initialized Amplify")
  } catch {
//    need to build out more robust error handling
    print("could not initialize Amplify: \(error)")
  }
}
