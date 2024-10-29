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

    init(user_id: String, name: String, phoneNumber: String, relationship: String) {
        self.user_id = user_id
        self.id = UUID().uuidString
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
    }
}

class EmergencyInfoViewModel: ObservableObject {
    @Published var userContacts: [EmergencyContactInfo] = []
    @Published var roommateContacts: [EmergencyContactInfo] = []
    @Published var errorMessage: String = ""
    @Published var showingErrorAlert = false

    private let lambdaInvoker = AWSLambdaInvoker.default()
    private var cancellables = Set<AnyCancellable>()

    // Fetch contacts for both user and roommate
    func fetchContacts(userID: String, roommateID: String) {
        let userContactsPublisher = fetchEmergencyContacts(for: userID)
        let roommateContactsPublisher = fetchEmergencyContacts(for: roommateID)

        Publishers.Zip(userContactsPublisher, roommateContactsPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.showingErrorAlert = true
                }
            } receiveValue: { [weak self] userContacts, roommateContacts in
                self?.userContacts = userContacts
                self?.roommateContacts = roommateContacts
            }
            .store(in: &cancellables)
    }

    // Helper to fetch contacts for a specific user
    private func fetchEmergencyContacts(for userID: String) -> Future<[EmergencyContactInfo], Error> {
        return Future { promise in
            let jsonObject: [String: Any] = [
                "queryStringParameters": ["user_id": userID]
            ]

            self.lambdaInvoker.invokeFunction("fetchEmergencyContacts", jsonObject: jsonObject).continueWith { task -> Any? in
                if let error = task.error {
                    promise(.failure(error))
                    return nil
                }

                guard let result = task.result as? [String: Any],
                      let bodyString = result["body"] as? String,
                      let bodyData = bodyString.data(using: .utf8) else {
                    promise(.failure(NSError(domain: "Invalid response structure", code: -1, userInfo: nil)))
                    return nil
                }

                do {
                    let body = try JSONSerialization.jsonObject(with: bodyData, options: []) as? [String: Any]
                    let contactData = body?["contacts"] as? [[String: Any]] ?? []
                    let contacts = try contactData.map { contact in
                        try JSONDecoder().decode(EmergencyContactInfo.self, from: JSONSerialization.data(withJSONObject: contact))
                    }
                    promise(.success(contacts))
                } catch {
                    promise(.failure(error))
                }

                return nil
            }
        }
    }

    // Add new contact
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
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
                return nil
            }

            DispatchQueue.main.async {
                self.userContacts.append(contact)
            }
            return nil
        }
    }

    // Delete contact
    func deleteContact(contactID: String, userID: String) {
        let jsonObject = [
            "queryStringParameters": ["user_id": userID, "contact_id": contactID]
        ] as [String: Any]

        lambdaInvoker.invokeFunction("deleteEmergencyContact", jsonObject: jsonObject).continueWith { task -> Any? in
            if let error = task.error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
                return nil
            }

            DispatchQueue.main.async {
                self.userContacts.removeAll { $0.id == contactID }
            }
            return nil
        }
    }
}
