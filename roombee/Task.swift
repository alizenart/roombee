////
////  File.swift
////  roombee
////
////  Created by Nicole Liu on 4/16/24.
////
//
//import Foundation
//
//struct Task: Identifiable {
//    let id = UUID()
//    var title: String
//    var status = false
//}
//
//
//extension Task {
//    static let samples = [
//    Task(title: "groceries"),
//    Task(title: "laundry"),
//    Task(title: "dishes")]
//}\

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
        Tasks(title: "Groceries", priority: .low, category: .shopping),
  ]
}

enum TaskPriority:String {
    case low = "low"
    case medium = "med"
    case high = "high"
}

enum TaskCategory {
    case shopping
    case chores
    case none
}
