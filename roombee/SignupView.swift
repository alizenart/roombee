//
//  SignupView.swift
//  roombee
//
//  Created by Adwait Ganguly on 4/15/24.
//

import SwiftUI
import Combine

struct SignupView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var shouldNavigate = false
    
    var body: some View {
        NavigationView {
            ZStack {
                viewModel.backgroundColor
                    .ignoresSafeArea()
                VStack {
                    
                    Text("Create Your Profile")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .foregroundColor(.init(red: 73/255, green: 73/255, blue: 73/255))
                    
                    Text("Email").padding(.horizontal, -120)
                        .padding(.bottom, -100)
                        .foregroundColor(Color.gray)
                        .font(.system(size: 15))
                    TextField("", text: $viewModel.email)
                        .padding()
                        .frame(width:250, height:50)
                        .overlay(Rectangle().frame(height: 1).padding(.top, 5), alignment: .bottomLeading)
                        .cornerRadius(10)
                        .padding(.bottom, 5)
                        .autocapitalization(.none)
                    
                    Text("Password").padding(.horizontal, -120)
                        .padding(.bottom, -100)
                        .padding(.top, 10)
                        .foregroundColor(Color.gray)
                        .font(.system(size: 15))
                    SecureField("", text: $viewModel.password)
                        .padding()
                        .frame(width:250, height:50)
                        .overlay(Rectangle().frame(height: 1).padding(.top, 5), alignment: .bottomLeading)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                        .autocapitalization(.none)
                    
                    Text("Confirm Password").padding(.horizontal, -120)
                        .padding(.bottom, -100)
                        .padding(.top, 10)
                        .foregroundColor(Color.gray)
                        .font(.system(size: 15))
                    SecureField("", text: $viewModel.confirmPassword)
                        .padding()
                        .frame(width:250, height:50)
                        .overlay(Rectangle().frame(height: 1).padding(.top, 5), alignment: .bottomLeading)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                        .autocapitalization(.none)
                    
                    Button(action: {
                        if viewModel.isValid {
                            shouldNavigate = true
                        }
                    }) {
                        if viewModel.authenticationState != .authenticating {
                            Text("Continue")
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!viewModel.isValid)
                    .frame(width: 250, height: 50)
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .padding()
                .background(Rectangle()
                    .foregroundColor(.init(red: 230/255, green: 217/255, blue: 197/255))
                    .cornerRadius(15)
                    .shadow(radius: 15))
                .padding()
                
                NavigationLink(destination: ContinueSignUp(), isActive: $shouldNavigate) { EmptyView() }
                
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignupView()
            SignupView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(AuthenticationViewModel())
    }
}
