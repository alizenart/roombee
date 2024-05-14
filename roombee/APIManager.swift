//
//  APIManager.swift
//  roombee
//
//  Created by Alison Bai on 4/29/24.
//
import SwiftUI

import Foundation

class APIManager: ObservableObject {
    static let shared = APIManager()
    static let baseURL = "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod"
    static let getTogglesEndpoint = "/toggle/?user_id="
    
    func fetchToggles(userId: Int, completion: @escaping ([ToggleInfo]?, Error?) -> Void) {
            let endpoint = APIManager.getTogglesEndpoint + "\(userId)"
            guard let url = URL(string: APIManager.baseURL + endpoint) else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }

                do {
                    print("JSON string data: \(String(data: data, encoding: .utf8))")
                    let toggles = try JSONDecoder().decode([ToggleInfo].self, from: data)
                    print("Toggles retrieved: ", toggles)
                    DispatchQueue.main.async {
                        completion(toggles, nil)
                    }
                } catch {
                    completion(nil, error)
                }
            }.resume()
        }
    
    
    func changeToggleState(userId: Int, state: String) {
        // Use the function parameters to build the userData dictionary
        
       
        
        let userData: [String: Any] = [
            "user_id": userId,
            "state": state
        ]

        // Serialize your data into JSON
        if let jsonData = try? JSONSerialization.data(withJSONObject: userData, options: []) {
            // Create the URL object
            guard let url = URL(string: "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod/toggle") else {
                print("Invalid URL")
                return
            }
            
            // Create the URLRequest object
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Create a URLSession task
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error occurred: \(error)")
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                    print("Server responded with status code: \(response.statusCode)")
                    return
                }
                
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data: \(dataString)")
                }
            }
            
            // Start the task
            task.resume()
        } else {
            print("Failed to serialize userData into JSON")
        }
    }//changeToggleState
    
    /*"event_id": 0,
      "user_id": 0,
      "event_title": "ROOMBEE LAUNCH",
      "start_time": "2024-05-02 10:30:00",
      "end_time": "2024-05-02 12:30:00",
      "approved": false
    */
    func getToggleState(userId: Int) {
        // Create the URL object with query parameters
        guard var urlComponents = URLComponents(string: "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod/toggle") else {
            print("Invalid URL")
            return
        }
        urlComponents.queryItems = [URLQueryItem(name: "user_id", value: String(userId))]
        
        // Create the URLRequest object
        guard let url = urlComponents.url else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Create a URLSession task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred: \(error)")
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                print("Server responded with status code: \(response.statusCode)")
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data: \(dataString)")
                // Depending on your application's requirements, you may process the response data here
            }
        }
        
        // Start the task
        task.resume()
    }

    
    func addEvent(eventId: Int, userId: Int, eventTitle: String, startTime: String, endTime: String, approved: Bool) {
        // Construct the URL with query string parameters
        guard var urlComponents = URLComponents(string: "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod/event") else {
            print("Invalid URL")
            return
        }
        
        // Add query string parameters
        urlComponents.queryItems = [
            URLQueryItem(name: "event_id", value: "\(eventId)"),
            URLQueryItem(name: "user_id", value: "\(userId)"),
            URLQueryItem(name: "event_title", value: eventTitle),
            URLQueryItem(name: "start_time", value: startTime),
            URLQueryItem(name: "end_time", value: endTime),
            URLQueryItem(name: "approved", value: "\(approved)")
        ]
        
        // Create the URL object
        guard let url = urlComponents.url else {
            print("Failed to create URL")
            return
        }
        
        // Create the URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Create a URLSession task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred: \(error)")
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                print("Server responded with status code: \(response.statusCode)")
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
        }
        
        // Start the task
        task.resume()
    }

}
