//
//  TestingAPI.swift
//  roombee
//
//  Created by Alison Bai on 4/22/24.
//


import Foundation

// Update the function to accept parameters
func sendUserData(userId: Int, state: String) {
    print("HI")
    // Use the function parameters to build the userData dictionary
    let userData: [String: Any] = [
        "user_id": userId,
        "state": state
    ]

    // Serialize your data into JSON
    if let jsonData = try? JSONSerialization.data(withJSONObject: userData, options: []) {
        print("check 2")
        // Create the URL object
        guard let url = URL(string: "https://fx8re4aqk0.execute-api.us-east-1.amazonaws.com") else {
            print("Invalid URL")
            return
        }

        print("check 3")
        
        // Create the URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("check 4")
        print(request)
        // Create a URLSession task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            print("hi1")
            
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
        print("check 5")
        // Start the task
        task.resume()
    } else {
        print("Failed to serialize userData into JSON")
    }
}

// Call the function with specific user_id and state
sendUserData(userId: 80003, state: "is_sleeping")
