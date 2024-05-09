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
    var eventStore = EventStore()
    
    var body: some Scene {
        WindowGroup {
  //        ContentView().environmentObject(eventStore)
            if authManager.isAuthenticated {
                HomepageView()
                    .environmentObject(EventStore())
                    .environmentObject(authManager)
                    .environmentObject(navManager)
                    .onAppear {
                      APIService.shared.fetchEvents { events, error in
                        if let events = events {
                          print("got events from api call \(events)")
                        } else if let error = error {
                          print("error fetching events: \(error)")
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

