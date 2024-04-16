//
//  SideMenuView.swift
//  roombee
//
//  Created by Ziye Wang on 4/15/24.
//

import SwiftUI

//struct SideMenuView: View {
//    @Binding var presentSideMenu: Bool
//    var body: some View {
//        ZStack {
//            toggleColor
//                .ignoresSafeArea()
//            VStack {
//                ProfileViewNav(presentSideMenu: .constant(true))
//                VStack(spacing: 10){
//                    HomeViewNav(presentSideMenu: .constant(true))
//                    TaskViewNav(presentSideMenu: .constant(true))
//                    SettingsViewNav(presentSideMenu: .constant(true))
//                    Spacer()
//                    SignOutViewNav(presentSideMenu: .constant(true))
//                }
//                .padding(.top, 30)
//                
//            }.padding()
//        }
//    }
//}
//
//struct ProfileViewNav: View {
//    @Binding var presentSideMenu: Bool
//    
//    var body: some View {
//        Image("ProfileIcon")
//            .resizable()
//            .frame(width: 150, height: 150)
//        Text("Username")
//    }
//}
//
//struct HomeViewNav: View {
//    @Binding var presentSideMenu: Bool
//    
//    var body: some View {
//        VStack{
//            HStack {
//                Button {
//                    presentSideMenu.toggle()}
//            label: {
//                Image("HomeIcon")
//                    .resizable()
//                    .frame( width: 32, height: 32)
//                Text("Home")
//                    .foregroundColor(.black)
//                }
//                Spacer()
//            }
//        }
//        .padding(.horizontal, 24)
//    }
//}
//
//struct TaskViewNav: View {
//    @Binding var presentSideMenu: Bool
//    
//    var body: some View {
//        VStack{
//            HStack {
//                Button {
//                    presentSideMenu.toggle()}
//            label: {
//                Image("TaskIcon")
//                    .resizable()
//                    .frame( width: 32, height: 32)
//                Text("Tasks")
//                }
//                Spacer()
//            }
//
//        }
//        .padding(.horizontal, 24)
//    }
//}
//
//struct SettingsViewNav: View {
//    @Binding var presentSideMenu: Bool
//    
//    var body: some View {
//        VStack{
//            HStack {
//                Button {
//                    presentSideMenu.toggle()}
//            label: {
//                Image("SettingIcon")
//                    .resizable()
//                    .frame( width: 32, height: 32)
//                Text("Settings")
//                }
//                Spacer()
//            }
//        }
//        .padding(.horizontal, 24)
//    }
//}
//
//struct SignOutViewNav: View {
//    @Binding var presentSideMenu: Bool
//    
//    var body: some View {
//        VStack{
//            HStack {
//                Button {
//                    presentSideMenu.toggle()}
//            label: {
//                Image("SignOutIcon")
//                    .resizable()
//                    .frame( width: 32, height: 32)
//                Text("Sign Out")
//
//                }
//                Spacer()
//            }
//
//        }
//        .padding(.horizontal, 24)
//    }
//}
//
//
////#Preview {
////    HomeSideBarView(presentSideMenu: Binding<true>)
////}
//
////#Preview {
////    SideMenuView()
////}
//
//struct SideMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        SideMenuView(presentSideMenu: .constant(true))
//    }
//}
//
