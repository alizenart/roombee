//
//  ContinueSignUp.swift
//  roombee
//
//  Created by Adwait Ganguly on 5/5/24.
//

//
//  SignupView.swift
//  roombee
//
//  Created by Adwait Ganguly on 4/15/24.
//

import SwiftUI
import Combine

struct ContinueSignUp: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    private func signUpWithEmailPassword() {
        Task {
            if await viewModel.signUpWithEmailPassword() == true {
                dismiss()
            }
        }
    }
    
    var body: some View {
        ZStack {
            viewModel.backgroundColor
                .ignoresSafeArea()
            VStack {
                
                Text("Create Your Profile")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .foregroundColor(.init(red: 73/255, green: 73/255, blue: 73/255))
                
                HStack{
                    DatePickerModule()
                    GenderPickerView()
                }
                
                Text("First Name").padding(.horizontal, -120)
                    .padding(.bottom, -100)
                    .foregroundColor(Color.gray)
                    .font(.system(size: 15))
                TextField("", text: $viewModel.firstName)
                    .padding()
                    .frame(width:250, height:50)
                    .overlay(Rectangle().frame(height: 1).padding(.top, 5), alignment: .bottomLeading)
                    .cornerRadius(10)
                    .padding(.bottom, 5)
                
                Text("Last Name").padding(.horizontal, -120)
                    .padding(.bottom, -100)
                    .foregroundColor(Color.gray)
                    .font(.system(size: 15))
                TextField("", text: $viewModel.lastName)
                    .padding()
                    .frame(width:250, height:50)
                    .overlay(Rectangle().frame(height: 1).padding(.top, 5), alignment: .bottomLeading)
                    .cornerRadius(10)
                    .padding(.bottom, 5)
                
                Button(action: signUpWithEmailPassword) {
                    if viewModel.authenticationState != .authenticating {
                        Text("Sign up")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    else {
                        ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.isValid)
                .frame(width:250, height:50)
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
            .background(Rectangle()
                .foregroundColor(.init(red: 230/255, green: 217/255, blue: 197/255))
                .cornerRadius(15)
                .shadow(radius: 15))
            .padding()
        }
    }
}

struct ContinueSignUpPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            ContinueSignUp()
            ContinueSignUp()
                .preferredColorScheme(.dark)
        }
        .environmentObject(AuthenticationViewModel())
    }
}
