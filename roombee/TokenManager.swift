//
//  TokenManager.swift
//  roombee
//
//  Created by Nicole Liu on 2/10/25.
//

import Foundation
import Combine

class TokenManager: ObservableObject {
    static let shared = TokenManager()
    @Published var fcmToken: String? = nil
    
    private init() {}
}
