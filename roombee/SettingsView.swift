//
//  SettingsView.swift
//  roombee
//
//  Created by Ziye Wang on 4/15/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var navManager: NavManager
    
    var body: some View {
        ZStack{
            backgroundColor
                .ignoresSafeArea()
            VStack {
                Text("Settings")
                    .font(.system(size: 30))
                    .foregroundColor(ourOrange)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                HStack {
                    Image("SignOutIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .foregroundColor(.white)
                    Text("Sign Out")
                        .foregroundColor(.white)
//                        .font(.system(size: 20))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                } //hstack
                .frame(width: 50, height: 50)
                .padding(.top)
                
                HStack {
                    Image("DeleteUserIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .foregroundColor(.red)
                    Text("Delete Account")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
//                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                } //hstck
                .frame(width: 50, height: 50)
                Spacer()

            }//vstack

        }
    }
}

#Preview {
    SettingsView()
}
