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
        print("in fetchToggles")
        let endpoint = ToggleViewModel.getTogglesEndpoint + "\(userId)"
        guard let url = URL(string: ToggleViewModel.baseURL + endpoint) else {
            Task { @MainActor in
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            }
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            Task { @MainActor in // Ensure UI updates occur on the main thread
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }

                do {
                    let toggles = try JSONDecoder().decode([ToggleInfo].self, from: data)
                    completion(toggles, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }.resume()
    }


    
    
    func changeToggleState(userId: String, state: String) {
        guard var urlComponents = URLComponents(string: "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod/toggle") else {
            print("Invalid URL")
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "user_id", value: userId),
            URLQueryItem(name: "state", value: state)
        ]
        
        guard let url = urlComponents.url else {
            print("Failed to create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            Task { @MainActor in // Ensure any potential UI updates occur on the main thread
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
        }
        
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
        print("in getToggleState")
        guard var urlComponents = URLComponents(string: "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod/toggle") else {
            print("Invalid URL")
            return
        }
        urlComponents.queryItems = [URLQueryItem(name: "user_id", value: String(userId))]
        
        guard let url = urlComponents.url else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            Task { @MainActor in // Ensure any potential UI updates occur on the main thread
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
        }
        
        task.resume()
    }

}
