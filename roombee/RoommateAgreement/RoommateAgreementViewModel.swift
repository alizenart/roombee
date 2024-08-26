//
//  RoommateAgreementViewModel.swift
//  roombee
//
//  Created by Ziye Wang on 8/24/24.
//

import Foundation

struct Agreement: Identifiable {
    let id = UUID()
    var title: String
    var dateCreated: Date
    var isRule: Bool
    
    //rules
    var tags: [String]?
    
    //items
    var itemOwner: String?
    var whoCanUse: String?
    var itemDetails: String?

}

class RoommateAgreementViewModel: ObservableObject {
    @Published var agreements: [Agreement] = []
    
    let tagDictionary: [String: Int] = [
        "Chores": 1,
        "Prohibitions": 2
    ]
    
    func addAgreement(_ agreement: Agreement) {
        agreements.append(agreement)
//        sortAgreements()
    }
    
//    func sortAgreements() {
//        agreements.sort { ($0.time ?? Date.distantFuture) < ($1.time ?? Date.distantFuture) }
//    }
    

}
