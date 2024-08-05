//
//  HomeSideBarView.swift
//  roombee
//
//  Created by Ziye Wang on 4/14/24.
//

import SwiftUI



struct HomeViewNav: View {
    @Binding var presentSideMenu: Bool
    
    var body: some View {
        VStack{
            HStack {
                Button {
                    presentSideMenu.toggle()}
            label: {
                Image("HomeIcon")
                    .resizable()
                    .frame( width: 32, height: 32)
                }
                Spacer()
            }
            Spacer()
            Text("Home")
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct TaskViewNav: View {
    @Binding var presentSideMenu: Bool
    
    var body: some View {
        VStack{
            HStack {
                Button {
                    presentSideMenu.toggle()}
            label: {
                Image("TaskIcon")
                    .resizable()
                    .frame( width: 32, height: 32)
                }
                Spacer()
            }
            Spacer()
            Text("Tasks")
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// Not used in current version, will implement later
struct SettingsViewNav: View {
    @Binding var presentSideMenu: Bool
    
    var body: some View {
        VStack{
            HStack {
                Button {
                    presentSideMenu.toggle()}
            label: {
                Image("SettingIcon")
                    .resizable()
                    .frame( width: 32, height: 32)
                }
                Spacer()
            }
            Spacer()
            Text("SettingsBeta")
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct AddRoommateViewNav: View {
    @Binding var presentSideMenu: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    presentSideMenu.toggle()}
            label: {
                Image("AddRoomateIcon")
                    .resizable()
                    .frame( width: 32, height: 32)
                }
                Spacer()
            }
            Spacer()
            Text("Add Roommate")
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}


struct SignOutViewNav: View {
    @Binding var presentSideMenu: Bool
    
    var body: some View {
        VStack{
            HStack {
                Button {
                    presentSideMenu.toggle()}
            label: {
                Image("SignOutIcon")
                    .resizable()
                    .frame( width: 32, height: 32)
                }
                Spacer()
            }
            Spacer()
            Text("Sign Out")
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

