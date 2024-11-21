//
//  NavManager.swift
//  roombee
//
//  Created by Ziye Wang on 4/15/24.
//

import SwiftUI

import Foundation
import Combine

@MainActor
class NavManager: ObservableObject {
    @Published var presentSideMenu = false
    @Published var selectedSideMenuTab = 0

    func openSideMenu() {
        withAnimation {
            presentSideMenu = true
        }
    }

    func closeSideMenu() {
        withAnimation {
            presentSideMenu = false
        }
    }

    func switchTab(to index: Int) {
        withAnimation {
            selectedSideMenuTab = index
        }
        closeSideMenu()
    }
}

