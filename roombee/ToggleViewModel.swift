//
//  ToggleViewModel.swift
//  roombee
//
//  Created by Alison Bai on 7/14/24.
//

import Foundation

import SwiftUI

struct ToggleInfo: Decodable {
    var userId: String
    var inRoom: Int
    var isSleeping: Int
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case inRoom = "in_room"
        case isSleeping = "is_sleeping"
    }
}

@MainActor
class ToggleViewModel: ObservableObject {
    static let shared = ToggleViewModel()
    static let baseURL = "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod"
    static let getTogglesEndpoint = "/toggle/?user_id="
    
    func fetchToggles(userId: String, completion: @escaping ([ToggleInfo]?, Error?) -> Void) {
            let endpoint = ToggleViewModel.getTogglesEndpoint + "\(userId)"
            guard let url = URL(string: ToggleViewModel.baseURL + endpoint) else {
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
    
    
    func changeToggleState(userId: String, state: String) {
        // Construct the URL with query string parameters
        guard var urlComponents = URLComponents(string: "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod/toggle") else {
            print("Invalid URL")
            return
        }
        
        // Add query string parameters
        urlComponents.queryItems = [
            URLQueryItem(name: "user_id", value: userId),
            URLQueryItem(name: "state", value: state)
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

            
    
    /*"event_id": 0,
      "user_id": 0,
      "event_title": "ROOMBEE LAUNCH",
      "start_time": "2024-05-02 10:30:00",
      "end_time": "2024-05-02 12:30:00",
      "approved": false
    */
    func getToggleState(userId: String) {
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
}
