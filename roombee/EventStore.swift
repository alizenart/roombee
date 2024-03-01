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
  }
}
