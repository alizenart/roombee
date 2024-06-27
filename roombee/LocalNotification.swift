//
//  LocalNofitif.swift
//  roombee
//
//  Created by Nicole Liu on 5/27/24.
//

import Foundation

struct LocalNotification {
    internal init(identifier: String, title: String, body: String,
                  timeInterval: Double, repeats: Bool) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.timeInterval = timeInterval
        self.dateComponent = nil
        self.repeats = repeats
    }
    
    internal init(identifier: String, title: String, body: String, dateComponent: DateComponents, repeats: Bool) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.timeInterval = nil
        self.dateComponent = dateComponent
        self.repeats = repeats
    }
    
    var identifier: String
    var title: String
    var body: String
    var timeInterval: Double?
    var dateComponent: DateComponents?
    var repeats: Bool
}
