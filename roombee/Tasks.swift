//
//  Tasks.swift
//  
//
//  Created by Nicole Liu on 4/15/24.
//

import Foundation

struct Tasks: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var status = false
}

extension Tasks {
    static let samples: [Tasks] = [
    Tasks(title: "Groceries", status: true),
    Tasks(title: "Laundry"),
    Tasks(title: "Dishes"),
    Tasks(title: "Trash"),
  ]
}
