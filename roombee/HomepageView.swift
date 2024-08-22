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

@MainActor
struct HomepageView: View {
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var selectedDateManager: SelectedDateManager
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var toggleManager: ToggleViewModel
    @EnvironmentObject var todoManager: TodoViewModel
    @EnvironmentObject var agreementManager: RoommateAgreementViewModel
    @EnvironmentObject var auth: AuthenticationViewModel
    
    @State private var isActive: Bool = true
    @State private var showInviteLinkPopup: Bool = false
    @State private var inviteLink: String = ""
    
    @State var isInitialLoad = true
    
    @State var myStatusToggleSleeping = false
    @State var myStatusToggleInRoom = false
    @State var roomieStatusToggleSleeping = false
    @State var roomieStatusToggleInRoom = false
    
    let myUserId = "80003"
    let roomieUserId = "80002"
    
    private func signOut() {
        authViewModel.signOut()
    }
    
    private func addRoommate() {
        inviteLink = "https://roombee.com/invite?hive_code=\(authViewModel.hive_code)"
        self.inviteLink = inviteLink
        showInviteLinkPopup = true
    }
    
    var body: some View {
        NavigationView {
            
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                Group {
                    switch navManager.selectedSideMenuTab {
                    case 0:
                        if authViewModel.isUserDataLoaded {
                            HomepageContent(
                                myStatusToggleSleeping: $myStatusToggleSleeping,
                                myStatusToggleInRoom: $myStatusToggleInRoom,
                                roomieStatusToggleSleeping: $roomieStatusToggleSleeping,
                                roomieStatusToggleInRoom: $roomieStatusToggleInRoom,
                                isInitialLoad: $isInitialLoad,
                                calGrid: GridView(cal: CalendarView(title: "Me")),
                                yourStatus: StatusView(title: "Me:", canToggle: true, isSleeping: $myStatusToggleSleeping, inRoom: $myStatusToggleInRoom, userId: auth.user_id ?? myUserId, isInitialLoad: $isInitialLoad),
                                roomStatus: StatusView(title: "Roommate:", canToggle: false, isSleeping: $roomieStatusToggleSleeping, inRoom: $roomieStatusToggleInRoom, userId: auth.roommate_id ?? roomieUserId, isInitialLoad: .constant(true))
                            )
                            .environmentObject(eventStore)
                            .environmentObject(authViewModel)
                            .environmentObject(navManager)
                            .environmentObject(selectedDateManager)
                            .environmentObject(toggleManager)
                            .environmentObject(todoManager)
                        }
                        
                    case 1:
                        ToDoView()
                    case 2:
                        EmptyView()
                    case 3:
                        RoommateAgreementView()
                            .environmentObject(agreementManager)
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
                if showInviteLinkPopup {
                    InviteLinkPopupView(inviteLink: inviteLink, isPresented: $showInviteLinkPopup)
                        .transition(.opacity)
                        .animation(.easeInOut, value: showInviteLinkPopup)
                }
            }
            .onChange(of: navManager.selectedSideMenuTab) { newValue in
                if newValue == 4 {
                    signOut()
                    navManager.selectedSideMenuTab = 0
                }
            }
            .onChange(of: navManager.selectedSideMenuTab) { newValue in
                if newValue == 2 {
                    addRoommate()
                    navManager.selectedSideMenuTab = 0
                }
            }
        }
        .onAppear {
            print("auth.user_id: \(auth.user_id ?? "No user ID")")
            fetchMyInitialToggleState(userId: auth.user_id ?? myUserId)
            fetchRoomieInitialToggleState(userId: auth.roommate_id ?? roomieUserId)
        }
    }
    private func fetchMyInitialToggleState(userId: String) {
        toggleManager.fetchToggles(userId: userId) { toggles, error in
            if let toggles = toggles, let firstToggle = toggles.first {
                DispatchQueue.main.async {
                    self.myStatusToggleSleeping = (firstToggle.isSleeping != 0)
                    self.myStatusToggleInRoom = (firstToggle.inRoom != 0)
                    print("Fetched toggle states for me: \(userId):")
                    print("isSleeping: \(self.myStatusToggleSleeping)")
                    print("inRoom: \(self.myStatusToggleInRoom)")
                }
            } else if let error = error {
                print("Error fetching toggles: \(error)")
            }
            DispatchQueue.main.async {
                self.isInitialLoad = false // Set to false after initial load
            }
        }
    }

    private func fetchRoomieInitialToggleState(userId: String) {
        toggleManager.fetchToggles(userId: userId) { toggles, error in
            if let toggles = toggles, let firstToggle = toggles.first {
                DispatchQueue.main.async {
                    self.roomieStatusToggleSleeping = (firstToggle.isSleeping != 0)
                    self.roomieStatusToggleInRoom = (firstToggle.inRoom != 0)
                    print("Fetched toggle states for roomie \(userId):")
                    print("isSleeping: \(self.roomieStatusToggleSleeping)")
                    print("inRoom: \(self.roomieStatusToggleInRoom)")
                }
            } else if let error = error {
                print("Error fetching toggles: \(error)")
            }
        }
    }

}
