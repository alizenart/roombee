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
    @EnvironmentObject var agreementManager: RoommateAgreementHandler
    @EnvironmentObject var agreementStore: RoommateAgreementStore
    @EnvironmentObject var auth: AuthenticationViewModel
    
    @State private var isActive: Bool = true
    @State private var showInviteLinkPopup: Bool = false
    @State private var inviteLink: String = ""
    
    @State var isInitialLoad = true
    
    @State var myStatusToggleSleeping = false
    @State var myStatusToggleInRoom = false
    @State var roomieStatusToggleSleeping = false
    @State var roomieStatusToggleInRoom = false
    
    private func refreshPage() async {
        print("Refreshing data...")
        // Fetch the user's and roommate's initial data again
        if let userId = auth.user_id {
            fetchMyInitialToggleState(userId: userId)
        }

        if let roommateId = auth.roommate_id {
            fetchRoomieInitialToggleState(userId: roommateId)
        }
        auth.getUserData() // Re-fetch user data
    }
    
    
    private func signOut() {
        authViewModel.signOut(eventStore: eventStore)
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
                            // Add the refreshable modifier here
                            ScrollView {
                                HomepageContent(
                                    myStatusToggleSleeping: $myStatusToggleSleeping,
                                    myStatusToggleInRoom: $myStatusToggleInRoom,
                                    roomieStatusToggleSleeping: $roomieStatusToggleSleeping,
                                    roomieStatusToggleInRoom: $roomieStatusToggleInRoom,
                                    isInitialLoad: $isInitialLoad,
                                    calGrid: GridView(cal: CalendarView(title: "Me")),
                                    yourStatus: auth.user_id != nil ? StatusView(
                                        title: "Me:",
                                        canToggle: true,
                                        isSleeping: $myStatusToggleSleeping,
                                        inRoom: $myStatusToggleInRoom,
                                        userId: auth.user_id!, // Forced unwrapping is safe here because of the check above
                                        isInitialLoad: $isInitialLoad
                                    ) : nil,
                                    roomStatus: StatusView(
                                        title: "Roommate:",
                                        canToggle: false,
                                        isSleeping: $roomieStatusToggleSleeping,
                                        inRoom: $roomieStatusToggleInRoom,
                                        userId: auth.roommate_id ?? "", // Forced unwrapping is safe here because of the check above
                                        isInitialLoad: .constant(true)
                                    )
                                )
                                .environmentObject(eventStore)
                                .environmentObject(authViewModel)
                                .environmentObject(navManager)
                                .environmentObject(selectedDateManager)
                                .environmentObject(toggleManager)
                                .environmentObject(todoManager)
                                .environmentObject(agreementManager)
                                .environmentObject(agreementStore)
                            }
                            .refreshable {
                                await refreshPage() // This will trigger the refresh logic
                            }
                        }
                    
                        else{
                            ProgressView("Loading...") // Optional label "Loading..."
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                               .scaleEffect(1.5) // Increase the size of the spinner
                        }
                        
                    case 1:
                        ToDoView()
                    case 2:
                        EmptyView()
                    case 3:
                        RoommateAgreementView()
                            .environmentObject(agreementStore)
                            .environmentObject(agreementManager)
                    case 4:
                        SettingsView()
                            .environmentObject(authViewModel)
                    default:
                        Text("Unknown Selection")
                    } //switch
                } //group
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
                        .frame(width: 20, height: 60)
                        .padding(.trailing, 50)
                        .frame(width: 400, alignment: .leading)
                    } // Hstack for nav button
                    .padding(.leading, 30)
                    .frame(width: 400, alignment: .leading)
                    Spacer()
                } //vstack for menu button
                
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
//            .onChange(of: navManager.selectedSideMenuTab) { newValue in
//                if newValue == 4 {
//                    signOut()
//                    navManager.selectedSideMenuTab = 0
//                }
//            }
            .onChange(of: navManager.selectedSideMenuTab) { newValue in
                if newValue == 2 {
                    addRoommate()
                    navManager.selectedSideMenuTab = 0
                }
            }
        }
        .onAppear {
            print("Authentication state: \(auth.authenticationState)")
            if auth.authenticationState == .authenticated {
                // User is already signed in, fetch user data
                if let userId = auth.user_id {
                    fetchMyInitialToggleState(userId: userId)
                }

                if let roommateId = auth.roommate_id {
                    fetchRoomieInitialToggleState(userId: roommateId)
                }
                auth.getUserData()
            } else {
                // Otherwise, make sure login happens first
                //auth.signIn()
            }
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
            auth.getUserData()
            }
        }
        .onChange(of: authViewModel.roommate_id) { newHiveCode in
            // Trigger fetching of toggles when hiveCode changes
            print("HiveCode updated to: \(newHiveCode)")
            fetchInitialToggles()
        }
        .onDisappear{
            NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }
    
    private func fetchInitialToggles() {
        if let userId = authViewModel.user_id {
                fetchMyInitialToggleState(userId: userId)
        }

        if let roommateId = authViewModel.roommate_id {
            fetchRoomieInitialToggleState(userId: roommateId)
        }
    }
    
    
    
    private func fetchMyInitialToggleState(userId: String) {
        print("Fetching my toggles for userId: \(userId)")
        toggleManager.fetchToggles(userId: userId) { toggles, error in
            if let toggles = toggles, let firstToggle = toggles.first {
                DispatchQueue.main.async {
                    self.myStatusToggleSleeping = (firstToggle.isSleeping != 0)
                    self.myStatusToggleInRoom = (firstToggle.inRoom != 0)
                    print("My toggles: Sleeping: \(self.myStatusToggleSleeping), In Room: \(self.myStatusToggleInRoom)")
                }
            } else if let error = error {
                print("Error fetching toggles: \(error)")
            }
            DispatchQueue.main.async {
                self.isInitialLoad = false
            }
        }
    }

    private func fetchRoomieInitialToggleState(userId: String) {
        print("Fetching roommate toggles for userId: \(userId)")
        toggleManager.fetchToggles(userId: userId) { toggles, error in
            if let toggles = toggles, let firstToggle = toggles.first {
                DispatchQueue.main.async {
                    self.roomieStatusToggleSleeping = (firstToggle.isSleeping != 0)
                    self.roomieStatusToggleInRoom = (firstToggle.inRoom != 0)
                    print("Roommate toggles: Sleeping: \(self.roomieStatusToggleSleeping), In Room: \(self.roomieStatusToggleInRoom)")
                }
            } else if let error = error {
                print("Error fetching toggles: \(error)")
            }
        }
    }
    




}
