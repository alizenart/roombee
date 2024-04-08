//
//  AuthStore.swift
//  roombee
//
//  Created by Ziye Wang on 4/6/24.
//


import Foundation
import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false

    func signIn(email: String, password: String) {

        self.isAuthenticated = true
    }

    func signOut() {
        self.isAuthenticated = false
    }
}
