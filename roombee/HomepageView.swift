//
//  HomepageView.swift
//  roombee
//
//  Created by Adwait Ganguly on 10/7/23.
//

import SwiftUI


let backgroundColor = Color(red: 56 / 255, green: 30 / 255, blue: 56 / 255)

let toggleColor = Color(red: 230 / 255, green: 217 / 255, blue: 197 / 255)

let ourOrange = Color(red: 221 / 255, green: 132 / 255, blue: 67 / 255)

let LighterPurple = Color(red: 124 / 255, green: 93 / 255, blue: 138 / 255)

let highlightYellow = Color(red: 230/255, green: 178/255, blue: 81/255)

let creamColor = Color(red:231/255, green:224/255, blue:215/255)


let date = Date()
let formatter = DateFormatter()

struct HomepageView: View {
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var selectedDateManager: SelectedDateManager


    @State private var isActive: Bool = true  // State to control navigation or visibility.

    var body: some View {
        ZStack {
            Group {
                switch navManager.selectedSideMenuTab {
                case 0:
                    HomepageContent(calGrid: GridView(cal: CalendarView(title: "Me")), yourStatus: StatusView(title: "Me:", canToggle: true), roomStatus: StatusView(title: "Roommate:", canToggle: false))
                        .environmentObject(EventStore())
                        .environmentObject(authManager)
                        .environmentObject(navManager)
                        .environmentObject(selectedDateManager)
                case 1:
                    ToDoView()
//                case 2:
//                    SettingsView()
//                        .environmentObject(EventStore())
//                        .environmentObject(authManager)
//                        .environmentObject(navManager)
                case 2:
                    EmptyView()  // Use EmptyView or another placeholder.
                default:
                    Text("Unknown Selection")
                }
            }

            VStack {
                HStack {
                    Button(action: {
                        navManager.openSideMenu()
                    }) {
                        VStack (spacing: 3){
                            Rectangle().foregroundColor(.white).frame(width: 30, height: 3).cornerRadius(5)
                            Rectangle().foregroundColor(.white).frame(width: 30, height: 3).cornerRadius(5)
                            Rectangle().foregroundColor(.white).frame(width: 30, height: 3).cornerRadius(5)
                        }
                    }
                    .padding(.trailing, 50)
                    .frame(width: 400, alignment: .leading)
                }
                .padding(.leading, 30)
                .frame(width: 400, alignment: .leading)
                Spacer()
            }

            if navManager.presentSideMenu {
                SideMenuView(navManager: navManager)
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut, value: navManager.presentSideMenu)
            }
        }
        .onChange(of: navManager.selectedSideMenuTab) { newValue in
            if newValue == 2 {
                authManager.signOut()
                navManager.selectedSideMenuTab = 0 
            }
        }
    }
}
