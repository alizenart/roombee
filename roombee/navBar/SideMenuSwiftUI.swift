//
//  SideMenuSwiftUI.swift
//  roombee
//
//  Created by Ziye Wang on 4/15/24.
//

import SwiftUI


enum SideMenuRowType: Int, CaseIterable {
    case home = 0
    case task = 1
    case addRoommate = 2
    case signout = 3
    
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .task:
            return "Task"
        case .addRoommate:
            return "Add Roommate"
        case .signout:
            return "Sign Out"
        }
    }
    
    var iconName: String {
        switch self {
        case .home:
            return "HomeIcon"
        case .task:
            return "TaskIcon"
        case .addRoommate:
            return "AddRoomateIcon"
        case .signout:
            return "SignOutIcon"
        }
    }
}

struct SideMenuView: View {
    @ObservedObject var navManager: NavManager
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    ProfileImageView()
                        .frame(height: 140)
                        .padding(.top, geometry.safeAreaInsets.top+30)
                        .padding(.bottom, 30)

                    ForEach(SideMenuRowType.allCases, id: \.self) { row in
                        RowView(isSelected: navManager.selectedSideMenuTab == row.rawValue, imageName: row.iconName, title: row.title) {
                            navManager.switchTab(to: row.rawValue)
                        }
                    }
                    .padding(.trailing, 10)
                    .padding(.leading, 10)
                    Spacer()
                }
                .frame(width: 270)
                .background(toggleColor) // Your custom toggle color
                .offset(x: navManager.presentSideMenu ? 0 : -270)
                .animation(.easeInOut(duration: 0.7), value: navManager.presentSideMenu)
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height+200)
            .background(Color.black.opacity(navManager.presentSideMenu ? 0.5 : 0))
            .edgesIgnoringSafeArea(.all) // Ignore safe area to cover full screen
            .onTapGesture {
                if navManager.presentSideMenu {
                    navManager.closeSideMenu()
                }
            }
        }
    }

    func ProfileImageView() -> some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Image("ProfileIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 50).stroke(LighterPurple.opacity(0.5), lineWidth: 10))
                    .cornerRadius(50)
                Spacer()
            }
            Text(authViewModel.firstName).font(.system(size: 18, weight: .bold)).foregroundColor(.black)
            Text(authViewModel.lastName).font(.system(size: 14, weight: .semibold)).foregroundColor(.black.opacity(0.5))
        }
    }

    func RowView(isSelected: Bool, imageName: String, title: String, action: @escaping () -> ()) -> some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                HStack(spacing: 20) {
                    Rectangle()
                        .fill(isSelected ? backgroundColor : .clear)
                        .frame(width: 5)
                    ZStack {
                        Image(imageName)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(isSelected ? .white : .gray)
                            .frame(width: 26, height: 26)
                    }
                    .frame(width: 30, height: 30)
                    Text(title)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(isSelected ? .white : .gray)
                    Spacer()
                }
            }
            .frame(height: 50)
            .background(isSelected ? backgroundColor : Color.clear)
            .cornerRadius(10)
        }
    }
}


struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(navManager: NavManager())
    }
}

