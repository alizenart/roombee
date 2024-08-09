//
//  EventStore.swift
//  roombee
//
//  Created by Alina Chen on 2/25/24.
//

import Foundation
import Combine

struct CalendarEvent: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var user_id: Int = 0
    var eventTitle: String = "(No title)"
    var startTime: Date
    var endTime: Date
    var approved: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "event_id"
        case user_id
        case eventTitle = "event_title"
        case startTime = "start_time"
        case endTime = "end_time"
        case approved
    }
    
    init(eventTitle: String, startTime: Date, endTime: Date) {
        self.id = UUID()
        self.user_id = 0
        self.eventTitle = eventTitle
        self.startTime = startTime
        self.endTime = endTime
        self.approved = false
    }
    
    // Equatable conformance
    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


class EventStore: ObservableObject {
  @Published var events: [CalendarEvent] = []
  
  func getEvents() {
    APIService.shared.fetchEvents { [weak self] newEvents, error in
      DispatchQueue.main.async {
          if let newEvents = newEvents {
              print("Fetched events successfully: \(newEvents)")
              self?.events = newEvents
          } else if let error = error {
              print("Error fetching events in EventStore: \(error.localizedDescription)")
          }
      }
    }
  }
  
  func addEvent(_ newEvent: CalendarEvent) {
   
//    add backend logic here 
    APIService.shared.addEvent(event: newEvent) { success, error in
      if success {
        DispatchQueue.main.async {
          self.events.append(newEvent)
          print("new event added successfully: ", newEvent)
        }
      } else if let error = error {
        print("Failed to add event: ", error)
      }
    }
    
    print("events array! \(events)")
  }
    
    func deleteEvent(eventId: String) {
            APIService.shared.deleteEvent(eventId: eventId) { [weak self] success, error in
                if success {
                    DispatchQueue.main.async {
                        self?.events.removeAll { $0.id.uuidString == eventId }
                        print("Event deleted successfully.")
                    }
                } else if let error = error {
                    print("Failed to delete event: ", error.localizedDescription)
                }
            }
        }
}
