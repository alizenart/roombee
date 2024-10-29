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
    
    init(user_id: String, name: String, phoneNumber: String, relationship: String) {
        self.user_id = user_id
        self.id = UUID().uuidString // Generate a unique ID
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
        let jsonObject = [
            "queryStringParameters": ["user_id": userID]
        ]
        
        lambdaInvoker.invokeFunction("fetchEmergencyContacts", jsonObject: jsonObject).continueWith { task -> Any? in
            if let error = task.error {
                print("Error fetching contacts: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
                return nil
            }
            
            if let data = task.result as? [String: Any],
               let contactData = data["contacts"] as? [[String: Any]] {
                let decoder = JSONDecoder()
                
                do {
                    let contacts = try contactData.map { try decoder.decode(EmergencyContactInfo.self, from: JSONSerialization.data(withJSONObject: $0)) }
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
