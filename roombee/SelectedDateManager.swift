//
//  SelectedDateManager.swift
//  roombee
//
//  Created by Ziye Wang on 4/21/24.
//

import SwiftUI

import Foundation
import Combine

class SelectedDateManager: ObservableObject {
    @Published var SelectedDate = Date()

    func isDateSelected(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(SelectedDate, inSameDayAs: date)
    }
    
    func showSelectedCalendar( _ date: Date) {
        
    }
//    func moveToNextWeek() {
//        if let newDate = Calendar.current.date(byAdding: .day, value: 7, to: SelectedDate) {
//            SelectedDate = newDate
//        }
//    }
//
//    func moveToPreviousWeek() {
//        if let newDate = Calendar.current.date(byAdding: .day, value: -7, to: SelectedDate) {
//            SelectedDate = newDate
//        }
//    }
    
    // need function that will open the grid view for SelectedDate
    
    // Function that changes the date button to be yellow when selected?
}
