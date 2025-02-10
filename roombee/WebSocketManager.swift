//
//  DynamoDBManager.swift
//  roombee
//
//  Created by Nicole Liu on 10/29/24.
//


import Foundation

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession(configuration: .default)
    private let webSocketURL = URL(string: "wss://8ci1qdrsne.execute-api.us-east-1.amazonaws.com/production/?hive_code=1")!
    
    @Published var latestMessage: String? // Observable property for updates
    
    init() {
        connect()
        print("Connection Successful")
    }

    // Connect to WebSocket
    func connect() {
        webSocketTask = urlSession.webSocketTask(with: webSocketURL)
        webSocketTask?.resume()
        listenForMessages()
    }

    // Listen for messages
    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self?.latestMessage = text // Publish new message
                    }
                case .data:
                    break
                @unknown default:
                    break
                }
            case .failure:
                break
            }
            self?.listenForMessages() // Keep listening
        }
    }

    // Send a message
    func sendMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("Error sending message: \(error)")
            }
        }
    }
    
    func sendToggleRequest(userId: String, state: String) {
            let payload: [String: Any] = [
                "user_id": userId,
                "state": state
            ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                let message = URLSessionWebSocketTask.Message.data(jsonData)
                
                webSocketTask?.send(message) { error in
                    if let error = error {
                        print("Error sending toggle request: \(error)")
                    } else {
                        print("Toggle request sent successfully!")
                    }
                }
            } catch {
                print("Failed to encode toggle request to JSON: \(error)")
            }
        }

    // Disconnect WebSocket
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
