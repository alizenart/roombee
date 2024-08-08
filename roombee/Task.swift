//
//  Tasks.swift
//
//
//  Created by Nicole Liu on 4/15/24.
//

import Foundation

struct Tasks: Identifiable, Hashable, Codable {
    var id = UUID()
    var todoTitle = ""
    var todoContent = ""
    var todoPriority: String
    var todoCategory: String
    var status: Int
    var userId: String

    init(from toDoInfo: ToDoInfo) {
        
        self.todoTitle = toDoInfo.todoTitle
        self.todoContent = toDoInfo.todoContent
        self.todoPriority = toDoInfo.todoPriority
        self.todoCategory = toDoInfo.todoCategory
        self.status = toDoInfo.todoStatus
        self.userId = toDoInfo.userId
    }
    
    init(todoTitle:String, todoContent:String, todoPriority: String, todoCategory: String) {
        self.todoTitle = todoTitle
        self.todoContent = todoContent
        self.todoPriority = todoPriority
        self.todoCategory = todoCategory
        self.status = 0
        self.userId = "80003"
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
