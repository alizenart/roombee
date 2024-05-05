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
    
    // need function that will open the grid view for SelectedDate
    
    // Function that changes the date button to be yellow when selected?
}
