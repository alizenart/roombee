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
    
    private func signOut() {
        authViewModel.signOut()
    }
    
    var calGrid: GridView
    var yourStatus: StatusView
    var roomStatus: StatusView
    
    //new variables -z
    var schedCara: DatesCarousel {
        let dates = generateDates(startingFrom: Date(), count: 7) // Adjust parameters as needed
        return DatesCarousel(dates: dates, onDateSelected: { _ in }, selectedDate: .constant(Date()))
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor // Use the custom color here
                    .ignoresSafeArea()
                Group {
                    switch navManager.selectedSideMenuTab {
                    case 0:
                        HomepageContent(calGrid: GridView(cal: CalendarView(title: "Me")), yourStatus: StatusView(title: "Me:", canToggle: true), roomStatus: StatusView(title: "Roommate:", canToggle: false))
                            .environmentObject(EventStore())
                            .environmentObject(authViewModel)
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
    }
}
