//
//  SettingsView.swift
//  roombee
//
//  Created by Ziye Wang on 4/15/24.
//

import SwiftUI
import Mixpanel
import AWSS3
import AWSCore

struct SettingsView: View {
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var eventStore: EventStore
    
    @State private var showAboutRoombee = false
    @State private var showDeleteAccount = false
    
    @State private var profileImage: UIImage? // Store selected image
    @State private var isShowingImagePicker = false // Toggle ImagePicker



    
    private func signOut() {
        authViewModel.signOut(eventStore: eventStore)
        navManager.selectedSideMenuTab = 0
    }

    
    var body: some View {
        ZStack{
            GeometryReader{ geometry in
                backgroundColor
                    .ignoresSafeArea()
                VStack {
                    Text("Settings")
                        .font(.system(size: 30))
                        .foregroundColor(ourOrange)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                    
                    ProfileImageView()
                        .padding()
                        .onTapGesture {
                            isShowingImagePicker = true // Open Image Picker
                        }
                        .environmentObject(authViewModel)


                    // About Roombee Button
                    Button(action: {
                        showAboutRoombee = true
                        Mixpanel.mainInstance().track(event: "AboutRoombee")
                    }){
                        HStack {
                            Image(systemName: "info.square.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                            Text("About Roombee")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        } //hstack
                        .frame(height: 40)
                        .padding(.horizontal, 40)
                    }//button
                    .padding(.top)
                    .padding(.bottom)
                    .sheet(isPresented: $showAboutRoombee) {
                        AboutRoombeeView()
                    } // Sheet for About Roombee
                    
                    
                    Divider()
                        .background(Color.white) // Optional: Set color for the divider
                        .padding(.horizontal, 20) // Optional: Control padding for the divider

                    
                    //Button to sign-out
                    Button(action: signOut){
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                            Text("Sign Out")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        } //hstack
                        .frame(height: 40)
                        .padding(.horizontal, 40)
                    }//button
                    .padding(.top)
                    .padding(.bottom)
                    
                    Divider()
                        .background(Color.white)
                        .padding(.horizontal, 20)

                    
                    //Delete account button
                    Button (action: {showDeleteAccount = true}) {
                        HStack {
                            Image(systemName: "person.slash.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.red)
                            Text("Delete Account")
                                .foregroundColor(.red)
                                .font(.system(size: 20))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.red)
                                .font(.system(size: 20))
                        } //hstck
                        .frame(height: 40)
                        .padding(.horizontal, 40)
                    }//button
                    .padding(.top)
                    .sheet(isPresented: $showDeleteAccount) {
                        DeleteAccountWarningView()
                    } // Sheet for Delete Account
                    
                    
                    Spacer()
                    
                    
                    VStack(spacing: 5) {
                        Text("Feedback/questions?")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        Text("Contact us at")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        Text("roombeeapp@gmail.com")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .underline()
                    } //vstack
                    
                }//vstack
                


                
            }//geometry
        }//zstack
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $profileImage) { image in
                uploadImageToS3(image)
            }
        } //sheet
    }//body
    func ProfileImageView() -> some View {
        print("in ProfileImageView")
        print("authViewModel.profileImageURL: " , authViewModel.profileImageURL)
        return VStack(alignment: .center) {
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
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.purple.opacity(0.5), lineWidth: 10))
                        case .failure:
                            fallbackProfileImage()
                        }
                    }
                } else {
                    fallbackProfileImage()
                }
                Spacer()
            }
            Text("Change Image")
                .foregroundColor(.white)
                .font(.system(size: 14))
                .padding(.top, 3)
                .underline()
//            Text(authViewModel.user_firstName).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
//            Text(authViewModel.user_lastName).font(.system(size: 14, weight: .semibold)).foregroundColor(.white))
        }
    }
    
    func fallbackProfileImage() -> some View {
        Image("ProfileIcon")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 150)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.purple.opacity(0.5), lineWidth: 10))
    }

    
    func uploadImageToS3(_ image: UIImage) {
        print("uploadImageToS3 called")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let fileName = "profilePictures/\(authViewModel.user_id ?? "hello").jpg"
        let s3BucketName = "roombee-profile-pictures"
        let s3Url = "https://\(s3BucketName).s3.amazonaws.com/\(fileName)"

        let uploadRequest = AWSS3TransferUtilityUploadExpression()

        AWSS3TransferUtility.default().uploadData(
            imageData,
            bucket: s3BucketName,
            key: fileName,
            contentType: "image/jpeg",
            expression: uploadRequest
        ) { task, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
            } else {
                print("Successfully uploaded image to: \(s3Url)")

                // Save the image locally
                self.saveImageLocally(image)

                // Ensure the profile image URL update happens on the main thread
                DispatchQueue.main.async {
                    let timestamp = Int(Date().timeIntervalSince1970)
                    authViewModel.profileImageURL = "\(s3Url)?v=\(timestamp)"
                    self.authViewModel.updateProfilePictureURL(s3Url: "\(s3Url)?v=\(timestamp)")
                }
            }
        }
    }

    // Helper function to save the image locally
    private func saveImageLocally(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 1.0) {
            let fileURL = getDocumentsDirectory().appendingPathComponent("profileImage.jpg")
            do {
                try data.write(to: fileURL)
                print("Image saved locally at: \(fileURL)")
            } catch {
                print("Error saving image locally: \(error)")
            }
        }
    }

    // Helper function to get the document directory path
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}


struct AboutRoombeeView: View {
    var body: some View {
        NavigationView {
            Form {
//                backgroundColor.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 15) { // Adjust spacing as needed
                    Text("Roombee is founded by a group of Northwestern University students at The Garage, the university's startup incubator. Alison Bai, a junior at Northwestern, came up with the idea while navigating the experiences of living with roommates. It is co-created by Alison, Ziye Wang, and Nicole Liu")
                    
                    Text("With the help of like-minded peers, Roombee was born during a hackathon, where it won first place. Inspired by their success, the team decided to continue developing the project.")
                }
                .multilineTextAlignment(.center)
                .padding() // Optional: Adjust padding for overall text block

            }//form
            .navigationBarTitle("About Roombee", displayMode: .inline)
        }//navigation
    }
}
struct DeleteAccountWarningView: View {
    @Environment(\.dismiss) var dismiss // Access the dismiss action
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    @State private var password: String = ""
    @State private var showingErrorAlert = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                VStack(spacing: 10) {
                    Text("Are you sure you want to delete your account?")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                    Text("This action cannot be undone.")
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Password input field
                SecureField("Enter your password to confirm", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                
                Button("Yes, delete my account") {
                    Task {
                        let success = await authViewModel.deleteAccount(withPassword: password)
                        if success {
                            dismiss()
                        } else {
                            showingErrorAlert = true
                            errorMessage = authViewModel.errorMessage
                        }
                    }
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .alert(isPresented: $showingErrorAlert) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
                
                Button("No, go back") {
                    dismiss()
                }
                .foregroundColor(.black)
                .padding()
                .background(Color.gray)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.bottom)
            }
            .navigationBarTitle("Delete Account", displayMode: .inline)
        }
    }
}



    

//#Preview {
//    SettingsView()
//}
