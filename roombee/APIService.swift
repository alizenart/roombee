//
//  APIService.swift
//  roombee
//
// handles the API calls for this app
//
//  Created by Alina Chen on 4/29/24.
//
import Foundation
class APIService {
  static let shared = APIService()
  static let baseURL = "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod"
  static let getEventsEndpoint = "/event/?user_id=1"
//  !! its not under this path right now
  static let addEventEndpoint = "/event/add"
  
//  completion(handler) allows func to run async, we can load the rest of the page
  func fetchEvents(completion: @escaping ([CalendarEvent]?, Error?) -> Void) {
//    var events: [CalendarEvent]
    guard let url = URL(string: APIService.baseURL + APIService.getEventsEndpoint) else {
      completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
      return
    }
    
    URLSession.shared.dataTask(with: url) { data, res, error in
      guard let data = data, error == nil else {
        completion(nil, error)
        return
      }
      
      do {
//        this isn't gonna work perfectly bc the fields don't completely line up
        print("json string data: \(String(data: data, encoding: .utf8))")
        let events = try JSONDecoder().decode([CalendarEvent].self, from: data)
        print("events grabbed: ", events)
        DispatchQueue.main.async {
          completion(events, nil)
        }
      } catch {
        completion(nil, error)
      }
    }.resume()
  }
}
