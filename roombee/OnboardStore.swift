//
//  OnboardStore.swift
//  roombee
//
//  Created by Ziye Wang on 4/14/24.
//

import SwiftUI
import Foundation
import Combine

class OnboardStore: ObservableObject {
    @Published var username: String = ""
    @Published var RoomName: String = ""
    @Published var HiveCode: String = ""


    func CreateRoom(roomName : String) {
        self.RoomName = roomName
    }

    func JoinRoom() {
        
    }
}
