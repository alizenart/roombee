//
//  EventStore.swift
//  roombee
//
//  Created by Alina Chen on 2/25/24.
//

import Foundation
import Combine

class EventStore: ObservableObject {
  @Published var events: [Event] = []
  
  func addEvent(_ newEvent: Event) {
    events.append(newEvent)
    
//    add backend logic here 
//    Amplify.DataStore.save(newEvent) { result in
//        switch result {
//        case .success(let savedEvent):
//            print("Event saved: \(savedEvent)")
//        case .failure(let error):
//            print("Error saving event: \(error)")
//        }
//    }
  }
}
