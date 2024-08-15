//
//  Tasks.swift
//
//
//  Created by Nicole Liu on 4/15/24.
//

import Foundation
struct Tasks: Identifiable, Hashable {
    var hiveCode:String
    var id:String
    var userId: String
    var todoTitle: String
    var todoPriority: String
    var todoCategory: String
    var status: Int

    // Initializer to create Tasks from ToDoInfo
    init(from toDoInfo: ToDoInfo) {
        self.hiveCode = toDoInfo.hiveCode
        self.id = toDoInfo.todoID
        self.userId = toDoInfo.userId
        self.todoTitle = toDoInfo.todoTitle
        self.todoPriority = toDoInfo.todoPriority
        self.todoCategory = toDoInfo.todoCategory
        self.status = toDoInfo.todoStatus
    }
    
    // Custom initializer to create Tasks with specific values
    init(todoTitle: String, todoPriority: String, todoCategory: String) {
        self.hiveCode = "1"
        self.userId = "80003"
        self.id = UUID().uuidString
        self.todoTitle = todoTitle
        self.todoPriority = todoPriority
        self.todoCategory = todoCategory
        self.status = 0
    }
}


extension Tasks {
    static let samples: [Tasks] = []
}

enum todoPriority:String {
    case low = "low"
    case medium = "med"
    case high = "high"
}

enum todoCategory: String {
    case none = "none"
    case shopping = "buy"
    case chores = "chore"
}
