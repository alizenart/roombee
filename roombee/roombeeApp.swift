//
//  roombeeApp.swift
//  roombee
//
//  Created by Adwait Ganguly on 10/7/23.
//

import SwiftUI

@main

struct roombeeApp: App {
    @StateObject var authManager = AuthManager()
    @StateObject var navManager = NavManager()
    @StateObject var selectedDate = SelectedDateManager()
    var eventStore = EventStore()
    
    var body: some Scene {
        WindowGroup {
  //        ContentView().environmentObject(eventStore)
            if authManager.isAuthenticated {
                HomepageView()
                    .environmentObject(EventStore())
                    .environmentObject(authManager)
                    .environmentObject(navManager)
                    .environmentObject(selectedDate)

            } else {
                SignUp()
                    .environmentObject(EventStore())
                    .environmentObject(authManager)
            }
        }
    }
  }

