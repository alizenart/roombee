//
//  TodoViewModel.swift
//  roombee
//
//  Created by Nicole Liu on 8/1/24.
//

import Foundation

import SwiftUI

struct ToDoInfo: Codable {
    var hiveCode: String
    var todoID: String
    var userId:String
    var todoTitle: String
    var todoPriority: String
    var todoCategory: String
    var todoStatus: Int
    
    enum CodingKeys: String, CodingKey {
        case hiveCode = "hive_code"
        case todoID = "todo_id"
        case userId = "user_id"
        case todoTitle = "todo_title"
        case todoPriority = "todo_priority"
        case todoCategory = "todo_category"
        case todoStatus = "todo_status"
    }
}

struct ToDoResponse: Codable {
    var message: String
    var data: [ToDoInfo]
}

class TodoViewModel: ObservableObject {
    static let shared = TodoViewModel()
    static let baseURL = "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod"
    static let getTodoEndpoint = "/todolist/?user_id="
    
    func fetchToDo(userId: String, completion: @escaping([ToDoInfo]?, Error?) -> Void) {
        let endpoint = TodoViewModel.getTodoEndpoint + "\(userId)"
        guard let url = URL(string: TodoViewModel.baseURL + endpoint) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        URLSession.shared.dataTask(with:  url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ToDoResponse.self, from: data)
                print("Fetched tasks: \(response.data)")
                DispatchQueue.main.async {
                    completion(response.data, nil)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }
    
    func addToDo(todoID: String, userId: String, hiveCode: String, todoTitle: String, todoPriority: String, todoCategory: String, todoStatus: String) {
        guard var urlComponents = URLComponents(string: TodoViewModel.baseURL + "/todolist") else {
            print("Invalid URL")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "hive_code", value: hiveCode),
            URLQueryItem(name: "todo_id", value:todoID),
            URLQueryItem(name: "user_id", value: userId),
            URLQueryItem(name: "todo_title", value: todoTitle),
            URLQueryItem(name: "todo_priority", value: todoPriority),
            URLQueryItem(name: "todo_category", value: todoCategory),
            URLQueryItem(name: "todo_status", value:todoStatus)
        ]
        
        guard let url = urlComponents.url else {
            print("Failed to make URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred: \(error)")
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                print("Server responded with status code: \(response.statusCode)")
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
        }
        task.resume()
    }
    
    func updateTodo(todoID: String, todoStatus:String) {
        guard var urlComponents = URLComponents(string: TodoViewModel.baseURL + "/todolist") else {
            print("Invalid URL")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "todo_id", value: todoID),
            URLQueryItem(name: "todo_status", value:todoStatus),
            ]
        guard let url = urlComponents.url else {
            print("Failed to make URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred: \(error)")
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                print("Server responded with status code: \(response.statusCode)")
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
        }
        task.resume()
    }
    
    func deleteTodo(todoID: String) {
        guard var urlComponents = URLComponents(string: TodoViewModel.baseURL + "/todolist") else {
            print("Invalid URL")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "todo_id", value: todoID),
            ]
        guard let url = urlComponents.url else {
            print("Failed to make URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred: \(error)")
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                print("Server responded with status code: \(response.statusCode)")
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
        }
        task.resume()
    }
}
