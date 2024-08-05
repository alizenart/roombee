//
//  TodoViewModel.swift
//  roombee
//
//  Created by Nicole Liu on 8/1/24.
//

import Foundation

import SwiftUI

struct ToDoInfo: Decodable {
    var userId:String
    var todoTitle: String
    var todoContent: String
    var todoPriority: String
    var todoCategory: String
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case todoTitle = "todo_title"
        case todoContent = "todo_content"
        case todoPriority = "todo_priority"
        case todoCategory = "todo_category"
    }
}

class TodoViewModel: ObservableObject {
    static let shared = TodoViewModel()
    static let baseURL = "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod"
    static let getTodoEndpoint = "/toggle/?user_id="
    
    func fetchToDo(userId: String, completion: @escaping([ToDoInfo]?, Error?)->Void) {
        let endpoint = TodoViewModel.getTodoEndpoint + "\(userId)"
        guard let url = URL(string: TodoViewModel.baseURL + endpoint) else {
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
                let todoitem = try JSONDecoder().decode([ToDoInfo].self, from: data)
                print("Todo received: ", todoitem)
                DispatchQueue.main.async {
                    completion(todoitem, nil)
                }
            }
            catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func addToDo(userId: String, todo_title: String, todo_content: String, todo_priority: String, todo_category: String) {
        guard var urlComponents = URLComponents(string: "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod/todo") else {
            print("Invalid URL")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "user_id", value: userId),
            URLQueryItem(name: "todo_title", value: todo_title),
            URLQueryItem(name: "todo_content", value: todo_content),
            URLQueryItem(name: "todo_category", value: todo_category),
            URLQueryItem(name: "todo_priority", value: todo_priority)]
        
        guard let url = urlComponents.url else {
            print("Failed to make URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occured: \(error)")
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
    
    func getToDo(userId: String, state: String) {
        guard var urlComponents = URLComponents(string: "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod/todo") else {
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
            if let error = error {
                print("Error occured: \(error)")
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
        task.resume()
    }
}
