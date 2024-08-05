//
//  Tasks.swift
//
//
//  Created by Nicole Liu on 4/15/24.
//

import Foundation

struct Tasks: Identifiable, Hashable, Equatable {
    let id = UUID()
    var title: String
    var status = false
    var priority: TaskPriority
    var category: TaskCategory
}

extension Tasks {
    static let samples: [Tasks] = [
        Tasks(title: "Groceries", priority: .low, category: .none),
  ]
}

enum TaskPriority:String {
    case low = "low"
    case medium = "med"
    case high = "high"
}

enum TaskCategory: String {
    case none = "none"
    case shopping = "buy"
    case chores = "chore"
}
