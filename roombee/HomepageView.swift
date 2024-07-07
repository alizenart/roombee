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
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var selectedDateManager: SelectedDateManager
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var apiManager: APIManager

    @State private var isActive: Bool = true  // State to control navigation or visibility.
    
    @Binding var demoIsSleeping: Bool
    @Binding var demoInRoom: Bool
    @State var isInitialLoad = true
    
    @State var myStatusToggleSleeping = false
    @State var myStatusToggleInRoom = false
    @State var roomieStatusToggleSleeping = false
    @State var roomieStatusToggleInRoom = false
    
    
    let myUserId = "80003"
    let roomieUserId = "80002"
    
    var body: some View {
        ZStack {
            if isInitialLoad {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .foregroundColor(ourOrange)
                    .background(backgroundColor.ignoresSafeArea())
            } else {
                Group {
                    switch navManager.selectedSideMenuTab {
                    case 0:
                        HomepageContent(
                            myStatusToggleSleeping: $myStatusToggleSleeping,
                            myStatusToggleInRoom: $myStatusToggleInRoom,
                            roomieStatusToggleSleeping: $roomieStatusToggleSleeping,
                            roomieStatusToggleInRoom: $roomieStatusToggleInRoom,
                            isInitialLoad: $isInitialLoad,
                            calGrid: GridView(cal: CalendarView(title: "Me")),
                            yourStatus: StatusView(title: "Me:", canToggle: true, isSleeping: $myStatusToggleSleeping, inRoom: $myStatusToggleInRoom, userId: myUserId, isInitialLoad: $isInitialLoad),
                            roomStatus: StatusView(title: "Roommate:", canToggle: false, isSleeping: $roomieStatusToggleSleeping, inRoom: $roomieStatusToggleInRoom, userId: roomieUserId, isInitialLoad: .constant(true))
                        )
                        .environmentObject(EventStore())
                        .environmentObject(authManager)
                        .environmentObject(navManager)
                        .environmentObject(apiManager)
                    case 1:
                        ToDoView()
                    case 2:
                        SettingsView()
                            .environmentObject(EventStore())
                            .environmentObject(authManager)
                            .environmentObject(navManager)
                    case 3:
                        EmptyView()  // Use EmptyView or another placeholder.
                    default:
                        Text("Unknown Selection")
                    }
                }
                //                ScrollView {
                //                    VStack {
                //                        // Button("Sign Out", role: .cancel, action: signOut)
                //                        Text("Roombee")
                //                            .font(.largeTitle)
                //                            .foregroundColor(ourOrange)
                //                            .fontWeight(.bold)
                //                            .padding(.top, 20)
                //
                //                        HStack(spacing: 20){
                //                            yourStatus
                //                            roomStatus
                //                        }.padding(.horizontal, 40)
                //                        //                        .padding(.bottom, 20)
                //                            .padding(.top, 20)
                //
                //                        schedCara
                //                            .padding()
                //                        calGrid.padding([.leading, .trailing], 20)
                //                    }
                //                }
                //            }.navigationBarItems(leading: Button(action: signOut) {
                //                Text("Sign Out")
                //                    .bold()
                //                    .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                //                    .foregroundColor(.black) // Set the text color to black
                //                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Maximize size within the button frame
                //                    .background(toggleColor) // Set the background color to white
                //                    .cornerRadius(5) // Optional: if you want rounded corners
                //            })
                //            .navigationBarTitleDisplayMode(.inline)
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
                    signOut()
                    navManager.selectedSideMenuTab = 0
                }
            }
        }
        .onAppear {
            fetchMyInitialToggleState(userId: myUserId)
            fetchRoomieInitialToggleState(userId: roomieUserId)
        }
    }


    private func fetchMyInitialToggleState(userId: String) {
        apiManager.fetchToggles(userId: userId) { toggles, error in
            if let toggles = toggles, let firstToggle = toggles.first {
                DispatchQueue.main.async {
                    myStatusToggleSleeping = (firstToggle.isSleeping != 0)
                    myStatusToggleInRoom = (firstToggle.inRoom != 0)
                    print("Fetched toggle states for user \(userId):")
                    print("isSleeping: \(myStatusToggleSleeping)")
                    print("inRoom: \(myStatusToggleInRoom)")
                }
            } else if let error = error {
                print("error fetching toggles: \(error)")
            }
            isInitialLoad = false // Set to false after initial load
        }
    }

    private func fetchRoomieInitialToggleState(userId: String) {
        apiManager.fetchToggles(userId: userId) { toggles, error in
            if let toggles = toggles, let firstToggle = toggles.first {
                DispatchQueue.main.async {
                    roomieStatusToggleSleeping = (firstToggle.isSleeping != 0)
                    roomieStatusToggleInRoom = (firstToggle.inRoom != 0)
                    print("Fetched toggle states for user \(userId):")
                    print("isSleeping: \(roomieStatusToggleSleeping)")
                    print("inRoom: \(roomieStatusToggleInRoom)")
                }
            } else if let error = error {
                print("error fetching toggles: \(error)")
            }
        }
    }
}
