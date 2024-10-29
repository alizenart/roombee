//
//  EmergencyInfoViewModel.swift
//  roombee
//
//  Created by Alison Bai on 10/29/24.
//

import Foundation
import Combine
import AWSLambda

struct EmergencyContactInfo: Codable, Identifiable {
    var user_id: String
    let id: String
    var name: String
    var phoneNumber: String
    var relationship: String

    enum CodingKeys: String, CodingKey {
        case user_id = "user_id"
        case id = "contact_id"
        case name = "name"
        case phoneNumber = "phone_number"
        case relationship = "relationship"
    }
    
    // Optional initializer if needed for mock data
    init(user_id: String, name: String, phoneNumber: String, relationship: String) {
        self.user_id = user_id
        self.id = UUID().uuidString
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
    }
}

class EmergencyInfoViewModel: ObservableObject {
    @Published var emergencyContacts: [EmergencyContactInfo] = []
    @Published var errorMessage: String = ""
    @Published var showingErrorAlert = false

    private let lambdaInvoker = AWSLambdaInvoker.default()
    private var cancellables = Set<AnyCancellable>()
    
    // Fetch all contacts for the given user
    func fetchContacts(userID: String) {
        let jsonObject: [String: Any] = [
            "queryStringParameters": ["user_id": userID]
        ]
        
        lambdaInvoker.invokeFunction("fetchEmergencyContacts", jsonObject: jsonObject).continueWith { task -> Any? in
            if let error = task.error {
                print("Error fetching contacts: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch contacts"
                    self.showingErrorAlert = true
                }
                return nil
            }
            
            guard let result = task.result as? [String: Any],
                  let bodyString = result["body"] as? String,
                  let bodyData = bodyString.data(using: .utf8) else {
                print("Invalid response structure")
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected response format"
                    self.showingErrorAlert = true
                }
                return nil
            }
            
            do {
                let body = try JSONSerialization.jsonObject(with: bodyData, options: []) as? [String: Any]
                guard let contactData = body?["contacts"] as? [[String: Any]] else {
                    print("Failed to find contacts in response body")
                    DispatchQueue.main.async {
                        self.errorMessage = "Unexpected response format"
                        self.showingErrorAlert = true
                    }
                    return nil
                }
                
                let decoder = JSONDecoder()
                let contacts = try contactData.map { contact in
                    try decoder.decode(EmergencyContactInfo.self, from: JSONSerialization.data(withJSONObject: contact))
                }
                DispatchQueue.main.async {
                    self.emergencyContacts = contacts
                }
            } catch {
                print("Failed to decode contacts: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load contacts"
                    self.showingErrorAlert = true
                }
            }
            return nil
        }
    }


    
    // Add a new emergency contact
    func addContact(contact: EmergencyContactInfo) {
        let jsonObject = [
            "queryStringParameters": [
                "user_id": contact.user_id,
                "contact_id": contact.id,
                "name": contact.name,
                "phoneNumber": contact.phoneNumber,
                "relationship": contact.relationship
            ]
        ] as [String: Any]
        
        lambdaInvoker.invokeFunction("addEmergencyContact", jsonObject: jsonObject).continueWith { task -> Any? in
            if let error = task.error {
                print("Error adding contact: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
                return nil
            }
            
            DispatchQueue.main.async {
                self.emergencyContacts.append(contact)
            }
            return nil
        }
    }
    
    // Delete a contact by ID
    func deleteContact(contactID: String, userID: String) {
        let jsonObject = [
            "queryStringParameters": ["user_id": userID, "contact_id": contactID]
        ] as [String: Any]
        
        lambdaInvoker.invokeFunction("deleteEmergencyContact", jsonObject: jsonObject).continueWith { task -> Any? in
            if let error = task.error {
                print("Error deleting contact: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
                return nil
            }
            
            DispatchQueue.main.async {
                self.emergencyContacts.removeAll { $0.id == contactID }
            }
            return nil
        }
    }
}
