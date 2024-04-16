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
    @Published var GlobalEmail: String = ""
    private var password: String = "" // Don't expose passwords directly

    func signIn(email: String, password: String) {
        self.isAuthenticated = true
        self.GlobalEmail = email
    }

    func signOut() {
        self.isAuthenticated = false
        self.GlobalEmail = ""
    }
    func createAccount() {
        self.isAuthenticated = true
        //Logic to communicate with Model here
    }
}
