//
//  SettingsView.swift
//  roombee
//
//  Created by Ziye Wang on 4/15/24.
//

import SwiftUI

struct SettingsView: View {
    // why ??? how does this work
    @EnvironmentObject var navManager: NavManager
    
    var body: some View {
        ZStack{
            backgroundColor
                .ignoresSafeArea()
            Text("Settings Page")
                .foregroundColor(.white)

        }
    }
}

#Preview {
    SettingsView()
}
