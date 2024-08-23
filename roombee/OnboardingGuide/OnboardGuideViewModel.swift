//
//  OnboardGuideViewModel.swift
//  roombee
//
//  Created by Ziye Wang on 8/20/24.
//

import Foundation
import SwiftUI



class OnboardGuideViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    
    let totalPages = 5
    
    func nextPage() {
        if currentPage < totalPages - 1 {
            withAnimation {
                currentPage += 1
            }
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            withAnimation {
                currentPage -= 1
            }
        }
    }
    
    func skipToLastPage() {
        withAnimation {
            currentPage = totalPages - 1
        }
    }
    
    var isLastPage: Bool {
        return currentPage == totalPages - 1
    }
    

}
