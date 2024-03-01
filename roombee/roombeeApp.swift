//
//  roombeeApp.swift
//  roombee
//
//  Created by Adwait Ganguly on 10/7/23.
//

import SwiftUI

@main
struct roombeeApp: App {
  var eventStore = EventStore()
  
  var body: some Scene {
      WindowGroup {
        ContentView().environmentObject(eventStore)
      }
  }
}
