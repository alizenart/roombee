//
//  EventStore.swift
//  roombee
//
//  Created by Alina Chen on 2/25/24.
//

import Foundation
import Combine

struct CalendarEvent: Identifiable, Codable {
  var id = UUID() // this is the event id, need this name for identfiable protocol
  var user_id: Int = 0
  var eventTitle: String = "(No title)"
  var startTime: Date
  var endTime: Date
  var approved: Bool = false
  
  enum CodingKeys: String, CodingKey {
       case id = "event_id"
       case user_id
       case eventTitle = "title"
       case startTime = "start_time"
       case endTime = "end_time"
       case approved
   }
}

class EventStore: ObservableObject {
  @Published var events: [CalendarEvent] = []
  
  func getEvents() {
    
  }
  
  func addEvent(_ newEvent: CalendarEvent) {
    events.append(newEvent)
    print("new event: ", newEvent)
    
//    add backend logic here 

  }
}
