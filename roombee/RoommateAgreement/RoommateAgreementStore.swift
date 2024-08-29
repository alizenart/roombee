//
//  RoommateAgreementStore.swift
//  roombee
//
//  Created by Ziye Wang on 8/24/24.
//

import Foundation

struct Agreement: Identifiable {
    let id: String
    var title: String
    var dateCreated: Date
    var isRule: Bool
    
    //rules
    var tags: [String]?
    
    //items
    var itemOwner: String?
    var whoCanUse: String?
    var itemDetails: String?
    
    init(from AgreementInfo: AgreementInfo) {
        self.id = AgreementInfo.id
        self.title = AgreementInfo.title
        self.dateCreated = Agreement.convert(date:AgreementInfo.dateCreated)
        self.tags = AgreementInfo.tags.components(separatedBy: ",")
        self.isRule = AgreementInfo.isRule == 0
        self.itemOwner = AgreementInfo.itemOwner
        self.whoCanUse = AgreementInfo.whoCanUse
        self.itemDetails = AgreementInfo.itemDetails
    }
    
    init(id: String, title:String, dateCreated:Date, isRule: Bool, tags:[String]?, itemOwner: String, whoCanUse: String, itemDetails: String) {
        self.id = id
        self.title = title
        self.dateCreated = dateCreated
        self.isRule = isRule
        self.tags = tags
        self.itemOwner = itemOwner
        self.whoCanUse = whoCanUse
        self.itemDetails = itemDetails
    }
    
    private static func convert(date: String) -> Date {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd" // SQL DATE format
           dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Set to UTC if needed
           dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing
           
           if let date = dateFormatter.date(from: date) {
               return date
           } else {
               return Date()
           }
       }
}


class RoommateAgreementStore: ObservableObject {
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
