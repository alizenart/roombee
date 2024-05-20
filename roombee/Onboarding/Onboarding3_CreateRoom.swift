//
//  Onboarding3-CreateRoom.swift
//  roombee
//
//  Created by Ziye Wang on 4/3/24.
//

import SwiftUI

struct Onboarding3_CreateRoom: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss

    let backgroundColor = Color(red: 56 / 255, green: 30 / 255, blue: 56 / 255)
    
    let toggleColor = Color(red: 230 / 255, green: 217 / 255, blue: 197 / 255)
    
    let textColor = Color(red: 73/255, green: 73/255, blue: 73/255)
    
    let strokeColor = Color(red: 190/255, green: 172/255, blue: 136/255)
    
    
    var body: some View {
        //        NavigationView{
        
        GeometryReader { geometry in
            
            ZStack{
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 10){
                    VStack{
                        Text("Create")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.init(textColor))
                            .padding(.bottom, 10)
                            .padding(.top, 20)
                        Text("What's the name of your hive?")
                            .frame(width: 275, alignment: .center)
                            .font(.system(size: 25, weight : .bold))
                            .foregroundColor(.init(textColor))
                        //                            .padding(.leading, 20)
                            .multilineTextAlignment(.center)
                            .padding()
                            .padding(.bottom, -5)
                            .padding(.top, -10)
                        
                        TextField("", text: $authViewModel.hive_name)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(width: 250, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(strokeColor, lineWidth: 2)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                                    .opacity(0.5)
                            )
                            .cornerRadius(10)
                            .padding(.bottom, 10)
                        
                        
                        
                        Text("This can be changed in settings later")
                            .font(.system(size: 12))
                            .foregroundColor(.init(textColor))
                            .padding(.bottom, 20)
                        
                        
                        
                        Button(action: signUpWithEmailPassword) {
                            Group {
                                if authViewModel.authenticationState != .authenticating {
                                    Text("Finish")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                } else {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .disabled(!authViewModel.isValid)
                        .frame(width: 250, height: 50)
                        .buttonStyle(.borderedProminent)
                        .padding()
                        
                        NavigationLink(destination: HomepageView()
                            .environmentObject(EventStore())
                            .environmentObject(authViewModel)
                            .environmentObject(NavManager())
                            .environmentObject(SelectedDateManager())){
                            EmptyView()
                        }
                        
                        //                            NavigationLink(destination: Onboarding2()) {
                        //                                Text("Go Back")
                        //                                    .font(.system(size : 20, weight: .bold))
                        //                                    .frame(width: 125, height: 40, alignment: .center)
                        //                                    .background(Color(red: 162 / 255, green: 154 / 255, blue: 165 / 255))
                        //                                    .foregroundColor(.white)
                        //                                    .cornerRadius(10)
                        //                            }//button
                        //                            .padding(.top, 10)
                        
                    } //vstack (mini)
                    .padding()
                    .background(Rectangle()
                        .foregroundColor(.init(toggleColor))
                        .cornerRadius(15)
                        .shadow(radius: 15))
                    .padding()
                    
                    
                }//vstack (big)
            }//zstack
            
            
            
        } //geometry reader
        //        }// Nav
        
    } //body
    
    
    func GoBack() {
        //going back to signup/login page
    }
    
    func GoToGenerateCode() {
        //create go to home logic
    }
    
    func JoinRoom() {
        //join room logic
    }
    private func signUpWithEmailPassword() {
        Task {
            if await authViewModel.signUpWithEmailPassword() == true {
                dismiss()
            }
        }
    }
} //Onboarding2


struct Onboarding3_CreateRoom_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding3_CreateRoom().environmentObject(AuthenticationViewModel())
    }
}
