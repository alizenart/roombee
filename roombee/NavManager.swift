//
//  NavManager.swift
//  roombee
//
//  Created by Ziye Wang on 4/15/24.
//

import SwiftUI

import Foundation
import Combine

class NavManager: ObservableObject {
    @Published var presentSideMenu = false
    @Published var selectedSideMenuTab = 0

    func openSideMenu() {
        presentSideMenu = true
    }

    func closeSideMenu() {
        presentSideMenu = false
    }

    func switchTab(to index: Int) {
        selectedSideMenuTab = index
        closeSideMenu()  
    }
}
