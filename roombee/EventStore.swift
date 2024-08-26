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
    var user_id: String
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
    
    init(user_id: String, eventTitle: String, startTime: Date, endTime: Date) {
        self.id = UUID()
        self.user_id = user_id
        self.eventTitle = eventTitle
        self.startTime = startTime
        self.endTime = endTime
        self.approved = false
    }
    //initializer, creating events from dictionary
      init?(from dictionary: [String: Any]) {
          guard let idString = dictionary["event_id"] as? String,
                let id = UUID(uuidString: idString),
                let user_id = dictionary["user_id"] as? String,
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
            
            eventTitle = try container.decode(String.self, forKey: .eventTitle)
            startTime = try container.decode(Date.self, forKey: .startTime)
            endTime = try container.decode(Date.self, forKey: .endTime)
            
            if let userIdInt = try? container.decode(Int.self, forKey: .user_id) {
                user_id = String(userIdInt)
            } else {
                user_id = try container.decode(String.self, forKey: .user_id)
            }
            
            // Decode approved as Int and convert to Bool
            let approvedInt = try container.decode(Int.self, forKey: .approved)
            approved = (approvedInt != 0)
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
    @Published var userEvents: [CalendarEvent] = []
    @Published var roommateEvents: [CalendarEvent] = []
    
    
    @MainActor func getUserEvents(user_id: String) {
        APIService.shared.fetchEvents(user_id: user_id) { [weak self] newEvents, error in
            DispatchQueue.main.async {
                if let newEvents = newEvents {
                    print("Fetched user events successfully: \(newEvents)")
                    self?.userEvents = newEvents
                } else if let error = error {
                    print("Error fetching user events in EventStore: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor func getRoommateEvents(roommate_id: String) {
        APIService.shared.fetchEvents(user_id: roommate_id) { [weak self] newEvents, error in
            DispatchQueue.main.async {
                if let newEvents = newEvents {
                    print("Fetched roommate events successfully: \(newEvents)")
                    self?.roommateEvents = newEvents
                } else if let error = error {
                    print("Error fetching roommate events in EventStore: \(error.localizedDescription)")
                }
            }
        }
    }

    @MainActor func getAllEvents(user_id: String, roommate_id: String) {
        getUserEvents(user_id: user_id)
        getRoommateEvents(roommate_id: roommate_id)
    }
    @MainActor func clearEvents() {
        self.userEvents.removeAll()
        self.roommateEvents.removeAll()// Clear all events
    }
  
    @MainActor func addEvent(user_id: String, _ newEvent: CalendarEvent) {
   
//    add backend logic here 
        APIService.shared.addEvent(user_id: user_id, event: newEvent) { success, error in
      if success {
        DispatchQueue.main.async {
          self.userEvents.append(newEvent)
          print("new event added successfully: ", newEvent)
        }
      } else if let error = error {
        print("Failed to add event: ", error)
      }
    }
    
        print("events array! \(self.userEvents) and \(self.roommateEvents)")
  }
    
    @MainActor func deleteEvent(eventId: String) {
            APIService.shared.deleteEvent(eventId: eventId) { [weak self] success, error in
                if success {
                    DispatchQueue.main.async {
                        self?.userEvents.removeAll { $0.id.uuidString == eventId }
                        print("Event deleted successfully.")
                    }
                } else if let error = error {
                    print("Failed to delete event: ", error.localizedDescription)
                }
            }
        }
}
