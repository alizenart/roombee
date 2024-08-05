//
//  EventStore.swift
//  roombee
//
//  Created by Alina Chen on 2/25/24.
//

import Foundation
import Combine

struct CalendarEvent: Identifiable, Codable {
  var id = UUID() // this is the event id, need this name for identfiable protocol, rn testing the int event id though
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
    
  //initializer, creating events from dictionary
  init?(from dictionary: [String: Any]) {
      guard let idString = dictionary["event_id"] as? String,
            let id = UUID(uuidString: idString),
            let user_id = dictionary["user_id"] as? Int,
            let eventTitle = dictionary["event_title"] as? String,
            let startTimeString = dictionary["start_time"] as? String,
            let endTimeString = dictionary["end_time"] as? String,
            let approvedInt = dictionary["approved"] as? Int else {
          return nil
      }

      self.id = id
      self.user_id = user_id
      self.eventTitle = eventTitle
      self.approved = (approvedInt != 0) // Assuming 0 is false and any non-zero value is true

      // Set up the date formatter for the date strings
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Adjust as necessary

      // Parse the date strings
      guard let startTime = dateFormatter.date(from: startTimeString),
            let endTime = dateFormatter.date(from: endTimeString) else {
          return nil
      }
      self.startTime = startTime
      self.endTime = endTime
  }
  // custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        user_id = try container.decode(Int.self, forKey: .user_id)
        eventTitle = try container.decode(String.self, forKey: .eventTitle)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        
        // Decode approved as Int and convert to Bool
        let approvedInt = try container.decode(Int.self, forKey: .approved)
        approved = (approvedInt != 0)
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
}
