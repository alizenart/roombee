//
//  DimmedBackgroundView.swift
//  roombee
//
//  Created by Ziye Wang on 11/20/24.
//

import SwiftUI

struct DimmedBackgroundView: View {
    var onTap: () -> Void
    
    var body: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .onTapGesture {
                onTap()
            }
    }
}


struct ParentView: View {
    @ObservedObject var navManager: NavManager
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var toggleManager: ToggleViewModel

    var body: some View {
        ZStack {
            // Main app content (HomepageView or other views)
//            HomepageView()
//                .environmentObject(navManager)
//                .environmentObject(authViewModel)
//                .environmentObject(eventStore)
//                .environmentObject(toggleManager)
            
            // Dimmed background, shown when the menu is open
            if navManager.presentSideMenu {
                DimmedBackgroundView {
                    withAnimation {
                        navManager.closeSideMenu()
                    }
                }
            }
            ZStack{
                if navManager.presentSideMenu {
                    SideMenuView(navManager: navManager)
                        .environmentObject(authViewModel)
                        .transition(.move(edge: .leading)) // Slide-in animation
                        
                }
//                .transition(.move(edge: .leading))
                
            }
            .transition(.move(edge: .leading))
            // Side menu

            
        } //zstack
        .animation(.easeInOut, value: navManager.presentSideMenu)
    }
}




//#Preview {
//    DimmedBackgroundView()
//}
