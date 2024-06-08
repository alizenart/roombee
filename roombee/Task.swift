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
        Tasks(title: "Groceries", priority: .chillin, category: .shopping),
  ]
}

enum TaskPriority:String {
    case chillin = "low"
    case medium = "medium"
    case urgent = "urgent"
}

enum TaskCategory {
    case shopping
    case chores
    case none
}
