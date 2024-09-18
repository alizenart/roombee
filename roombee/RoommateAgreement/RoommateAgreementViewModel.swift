//
//  RoommateAgreementHandler.swift
//  roombee
//
//  Created by Nicole Liu on 8/26/24.
//

import Foundation

struct AgreementInfo: Codable {
    var id: String
    var title: String
    var dateCreated: String
    var isRule: Int
    var tags: String
    var itemOwner: String
    var whoCanUse: String
    var itemDetails: String
    
    enum CodingKeys: String, CodingKey {
        case id = "agreement_id"
        case title = "agreement_title"
        case dateCreated = "date_created"
        case isRule = "is_rule"
        case tags = "agreement_tags"
        case itemOwner = "agreement_owner"
        case whoCanUse = "allowed_users"
        case itemDetails = "agreement_content"
        
    }
    
}

struct AgreementResponse: Codable {
    var message: String
    var data: [AgreementInfo]
}

class RoommateAgreementHandler: ObservableObject {
    static let shared = RoommateAgreementHandler()
    static let baseURL = "https://syb5d3irh2.execute-api.us-east-1.amazonaws.com/prod"
    static let getAgreementEndpoint = "/agreements/?user_id="
    
    @Published var userAgreements: [Agreement] = []
    @Published var roommateAgreements: [Agreement] = []
    
    
    func fetchUserAgreements(user_id: String) {
        fetchAgreement(for: user_id) { [weak self] agreements in
            DispatchQueue.main.async {
                self?.userAgreements = agreements
            }
        }
    }

    func fetchRoommateAgreements(roommate_id: String) {
        fetchAgreement(for: roommate_id) { [weak self] agreements in
            DispatchQueue.main.async {
                self?.roommateAgreements = agreements
            }
        }
    }

    func fetchAllAgreements(user_id: String?, roommate_id: String?) {
        if let userId = user_id {
            fetchUserAgreements(user_id: userId)
        }
        
        if let roommateId = roommate_id {
            fetchRoommateAgreements(roommate_id: roommateId)
        }
    }
    
    private func fetchAgreement(for userID: String, completion: @escaping ([Agreement]) -> Void) {
        let endpoint = RoommateAgreementHandler.getAgreementEndpoint + "\(userID)"
        guard let url = URL(string: RoommateAgreementHandler.baseURL + endpoint) else {
            print("Invalid URL")
            completion([])
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching agreements: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            do {
                print(String(data: data, encoding: .utf8) ?? "No data")

                let response = try JSONDecoder().decode(AgreementResponse.self, from: data)
                let agreements = response.data.map { Agreement(from: $0) }
                completion(agreements)
            } catch {
                print("Error decoding agreements: \(error)")
                completion([])
            }
        }.resume()
    }
    
    func addAgree(id: String, title:String, dateCreated: String, isRule: String, tags: String, itemOwner:String?, whoCanUse: String?, itemDetails: String) {
        guard var urlComponents = URLComponents(string: RoommateAgreementHandler.baseURL + "/agreements") else {
            print("Invalid URL")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "agreement_id", value: id),
            URLQueryItem(name: "agreement_title", value:title),
            URLQueryItem(name: "date_created", value: dateCreated),
            URLQueryItem(name: "is_rule", value: isRule),
            URLQueryItem(name: "agreement_tags", value: tags),
            URLQueryItem(name: "agreement_owner", value: itemOwner),
            URLQueryItem(name: "allowed_users", value: whoCanUse),
            URLQueryItem(name: "agreement_content", value:itemDetails)
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
    
    func deleteAgreement(agreementID: String) {
        guard var urlComponents = URLComponents(string: RoommateAgreementHandler.baseURL + "/agreements") else {
            print("Invalid URL")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "agreement_id", value: agreementID),
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


