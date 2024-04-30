//
//  TestingAPI.swift
//  roombee
//
//  Created by Alison Bai on 4/22/24.
//


import Foundation

// Update the function to accept parameters
func sendUserData(userId: Int, state: String) {
    // Use the function parameters to build the userData dictionary
    let userData: [String: Any] = [
        "user_id": userId,
        "state": state
    ]

    // Serialize your data into JSON
    if let jsonData = try? JSONSerialization.data(withJSONObject: userData, options: []) {
        // Create the URL object
        guard let url = URL(string: "https://ryo3s2u3i9.execute-api.us-east-1.amazonaws.com/prod") else {
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
}

// Call the function with specific user_id and state
//example use sendUserData(userId: 80003, state: "is_sleeping")

