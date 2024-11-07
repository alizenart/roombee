//
//  ProfilePictureView.swift
//  roombee
//
//  Created by Ziye Wang on 10/29/24.
//

import SwiftUI

struct ProfilePictureView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Binding var profileImage: UIImage?
    @Binding var isShowingImagePicker: Bool
    var width: CGFloat
    var imageURL: String? 

    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                if let imageUrl = authViewModel.profileImageURL, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: width, height: width)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(toggleColor, lineWidth: 7))
                        case .failure:
                            fallbackProfileImage()
                        }
                    }
                } else {
                    fallbackProfileImage()
                }
                Spacer()
            }
        }
        .onTapGesture {
            isShowingImagePicker = true
        }
    }

    func fallbackProfileImage() -> some View {
        Image("ProfileIcon")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: width) 
            .clipShape(Circle())
            .overlay(Circle().stroke(toggleColor, lineWidth: 7))
    }
}


//#Preview {
//    ProfilePictureView()
//}
