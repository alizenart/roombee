//
//  File.swift
//  roombee
//
//  Created by Nicole Liu on 4/16/24.
//

import Foundation

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var status = false
}


extension Task {
    static let samples = [
    Task(title: "groceries"),
    Task(title: "laundry"),
    Task(title: "dishes")]
}
