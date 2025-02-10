//
//  InviteLinkPopupView.swift
//  roombee
//
//  Created by Adwait Ganguly on 6/2/24.
//

import Foundation
import SwiftUI
import Mixpanel

struct InviteLinkPopupView: View {
    @EnvironmentObject var auth: AuthenticationViewModel
    let inviteLink: String
    @Binding var isPresented: Bool
    @State private var inputHiveCode: String = ""
    @ObservedObject var apiService = APIService.shared

    var body: some View {
        ZStack{
            Color.black
                .opacity(0.4)
                .ignoresSafeArea()
            VStack {
                Text("Your Hive Code")
                    .font(.headline)
                    .padding()
                Text("Share your Hive Code to connect with your roommate and join the same Hive! (2 roommate max)")
                    .padding()
                Text(auth.hive_code)
                    .padding()
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = auth.hive_code
                        }) {
                            Text("Hive Code")
                            Image(systemName: "doc.on.doc")
                        }
                    }
                Button(action: {
                    UIPasteboard.general.string = auth.hive_code
                    isPresented = false
                    Mixpanel.mainInstance().track(event: "CopyHive", properties: ["userID": auth.user_id])
                }) {
                    Text("Copy and Close")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                // TextField for user to input a hive_code
                TextField("Enter Hive Code to Join", text: $inputHiveCode)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Button to handle the submission of the input hive_code
                Button(action: {
                    APIService.shared.updateHiveCode(userId: auth.user_id ?? "default_user_id", hiveCode: inputHiveCode, viewModel: auth) { success, error in
                        if success {
                            auth.hive_code = inputHiveCode // Update the hive_code in the ViewModel
                            print("Hive code updated successfully!")
                            isPresented = false
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    Mixpanel.mainInstance().track(event: "AddRoommateButton", properties: ["userID": auth.user_id])
                    
                    
                }){
                    Text("Submit Hive Code")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .frame(width: 300, height: 500)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 20)
            .overlay(
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding()
                },
                alignment: .topTrailing
            )
            .padding()
            .alert(isPresented: .constant(APIService.shared.joinHiveAlert != nil)) {
                Alert(
                    title: Text(APIService.shared.joinHiveAlert ?? ""),
                    dismissButton: .default(Text("OK")) {
                        if APIService.shared.joinHiveSuccess {
                            isPresented = false
                        }
                        apiService.joinHiveAlert = nil
                    }
                )
            }
        }

    }
}
