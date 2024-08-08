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
  static let getEventsEndpoint = "/event/?user_id=0"
//  !! its not under this path right now
  static let addEventEndpoint = "/event"
  static let deleteEventEndpoint = "/event"
    
    // Delete an event from the server
    func deleteEvent(eventId: String, completion: @escaping (Bool, Error?) -> Void) {
        var urlComponents = URLComponents(string: APIService.baseURL + APIService.deleteEventEndpoint)
        urlComponents?.queryItems = [URLQueryItem(name: "event_id", value: eventId)]
        
        guard let url = urlComponents?.url else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(false, error)
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to delete event"]))
                if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                    print("Response body: \(responseString)")
                }
                return
            }
            
            print("Successfully deleted event with id: \(eventId)")
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }.resume()
    }
    
    
  

    
//  completion(handler) allows func to run async, we can load the rest of the page
  func fetchEvents(completion: @escaping ([CalendarEvent]?, Error?) -> Void) {
//    var events: [CalendarEvent]
    guard let url = URL(string: APIService.baseURL + APIService.getEventsEndpoint) else {
      completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
      return
    }
    
    URLSession.shared.dataTask(with: url) { data, res, error in
      guard let data = data, error == nil else {
        print("return before decode")
        completion(nil, error)
        return
      }
    
        if let rawString = String(data: data, encoding: .utf8) {
            print("Raw data from server: \(rawString)")
        }
      
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.custom)
            let events = try decoder.decode([CalendarEvent].self, from: data)
            DispatchQueue.main.async {
                completion(events, nil)
            }
        } catch {
            print("Error decoding JSON: \(error)")
            completion(nil, error)
        }
    }.resume()
  }
  
  func addEvent(event: CalendarEvent, completion: @escaping (Bool, Error?) -> Void) {
    let queryParams = [
        "event_id": "\(event.id)",
        "user_id": "\(event.user_id)",
        "event_title": event.eventTitle,
        "start_time": ISO8601DateFormatter().string(from: event.startTime),
        "end_time": ISO8601DateFormatter().string(from: event.endTime),
        "approved": "\(event.approved)"
    ]
    
    var urlComponents = URLComponents(string: APIService.baseURL + APIService.addEventEndpoint)
    
//    add query string parameters onto the URL
    let queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
    urlComponents?.queryItems = queryItems
    
    guard let url = urlComponents?.url else {
      completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
      return
    }
      
//    specify post request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      guard error == nil else {
        completion(false, error)
        return
      }
      
//      check if received a valid response
      guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add event"]))
        if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                    print("Response body: \(responseString)")
                }
        return
      }
      
      print("successfully added event with id: \(event.id)")
      
      DispatchQueue.main.async {
        completion(true, nil)
      }
    }.resume()
  }
}

extension DateFormatter {
    static var custom: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
}
