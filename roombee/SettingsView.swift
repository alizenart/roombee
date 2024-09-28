//
//  SettingsView.swift
//  roombee
//
//  Created by Ziye Wang on 4/15/24.
//

import SwiftUI
import Mixpanel

struct SettingsView: View {
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var authManager: AuthenticationViewModel
    @EnvironmentObject var eventStore: EventStore
    
    @State private var showAboutRoombee = false
    @State private var showDeleteAccount = false


    
    private func signOut() {
        authManager.signOut(eventStore: eventStore)
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
                
            }
        }
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
    @EnvironmentObject var authManager: AuthenticationViewModel
    
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
                        let success = await authManager.deleteAccount(withPassword: password)
                        if success {
                            dismiss()
                        } else {
                            showingErrorAlert = true
                            errorMessage = authManager.errorMessage
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



    

#Preview {
    SettingsView()
}
