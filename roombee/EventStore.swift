//
//  EventStore.swift
//  roombee
//
//  Created by Alina Chen on 2/25/24.
//

import Foundation
import Combine

class EventStore: ObservableObject {
  @Published var events: [CalendarEvent] = []
  
  func addEvent(_ newEvent: CalendarEvent) {
    events.append(newEvent)
    
//    add backend logic here 

  }
}
