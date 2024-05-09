//
//  EventStore.swift
//  roombee
//
//  Created by Alina Chen on 2/25/24.
//

import Foundation
import Combine

struct ToggleInfo: Decodable {
    var userId: Int
    var inRoom: Int
    var isSleeping: Int

    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case inRoom = "in_room"
        case isSleeping = "is_sleeping"
    }
}


class EventStore: ObservableObject {
  @Published var events: [CalendarEvent] = []
  
  func addEvent(_ newEvent: CalendarEvent) {
    events.append(newEvent)
    
//    add backend logic here 

  }
}
