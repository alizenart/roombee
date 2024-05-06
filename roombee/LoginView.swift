//
//  LoginView.swift
//  roombee
//
//  Created by Adwait Ganguly on 4/15/24.
//
import SwiftUI

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    
    private func signInWithEmailPassword() {
        Task {
            if await viewModel.signInWithEmailPassword() == true {
                dismiss()
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // viewModel.backgroundColor.ignoresSafeArea()
                NavigationView {
                    VStack {
                        Text("Login")
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
                        
                        Button(action: signInWithEmailPassword) {
                            if viewModel.authenticationState != .authenticating {
                                Text("Login")
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
                        .buttonStyle(.borderedProminent)
                        .frame(width:250, height:50)
                        
                        
                        HStack {
                            Text("Don't have an account yet?").font(.system(size: 15))
                            Button("Sign Up", action: viewModel.switchFlow)
                        }
                        .padding([.top, .bottom], 50)
                        
                        
                        NavigationLink(destination: SignupView(), isActive: $viewModel.showSignUp) {
                            EmptyView()
                        }
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
        .navigationBarBackButtonHidden(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
            LoginView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(AuthenticationViewModel())
    }
}
