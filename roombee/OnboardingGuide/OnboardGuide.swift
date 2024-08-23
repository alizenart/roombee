//
//  OnboardGuide.swift
//  roombee
//
//  Created by Ziye Wang on 8/19/24.
//

import SwiftUI

struct OnboardGuideView: View {
//    @ObservedObject var viewModel: OnboardGuideViewModel
    @EnvironmentObject var authModel: AuthenticationViewModel
    @EnvironmentObject var onboardGuideManager: OnboardGuideViewModel


    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack {
                if onboardGuideManager.currentPage == 0 {
                    OnboardGuide1().environmentObject(onboardGuideManager)
                } else if onboardGuideManager.currentPage == 1 {
                    OnboardGuide2().environmentObject(onboardGuideManager)
                } else if onboardGuideManager.currentPage == 2 {
                    OnboardGuide3().environmentObject(onboardGuideManager)
                } else if onboardGuideManager.currentPage == 3 {
                    OnboardGuide4().environmentObject(onboardGuideManager)
                } else if onboardGuideManager.currentPage == 4 {
                    OnboardGuide5().environmentObject(onboardGuideManager)
                        .environmentObject(authModel)
                }
            } //vstack
            .transition(.slide)
            .animation(.easeInOut, value: onboardGuideManager.currentPage)
        } //zstack
    }
}



struct OnboardGuide1: View {
    @EnvironmentObject var onboardGuideManager: OnboardGuideViewModel
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            VStack {
                HStack {
                    Button("Skip") {
                        onboardGuideManager.skipToLastPage()
                    }
                    .foregroundColor(.white)
                    .padding(.leading)
                    .padding(.top)
                    
                    Spacer()
                }//Hstack
                Spacer()
                VStack {
                    Text("Welcome to ")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    + Text("Roombee!")
                        .font(.largeTitle)
                        .foregroundColor(highlightYellow)
                    Text("We're so glad you're here")
                        .foregroundColor(.white)
                }
                .multilineTextAlignment(.center)
//                .padding()
               
                Spacer()
                
                Button(action: {
                    onboardGuideManager.nextPage()
                }) {
                    HStack {
                        Text("Begin Tour")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                            .opacity(1.0)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                    } // hstack
                    
                }//button
            }
        } //Zstack
    }
}


struct OnboardGuide2: View {
    @EnvironmentObject var onboardGuideManager: OnboardGuideViewModel
    
    var body: some View {
        ZStack {
            highlightYellow
                .ignoresSafeArea()
            VStack {
                HStack {
                    Button("Skip") {
                        onboardGuideManager.skipToLastPage()
                    }
                    .foregroundColor(.white)
                    .padding(.leading)
                    .padding(.top)
                    
                    Spacer()
                }//Hstack
                
                Spacer()
                Text("Stay updated on your roommate's status")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Image("Guide1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 30)

 
               
//                Spacer()
                HStack{
                    Button(action: {
                        onboardGuideManager.previousPage()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .opacity(1.0)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                    }//button
                    Button(action: {
                        onboardGuideManager.nextPage()
                    }) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                            .opacity(1.0)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                    }//button
                }
            }
        } //Zstack
    }
}

struct OnboardGuide3: View {
    @EnvironmentObject var onboardGuideManager: OnboardGuideViewModel
    
    var body: some View {
        ZStack {
            ourOrange
                .ignoresSafeArea()
            VStack {
                HStack {
                    Button("Skip") {
                        onboardGuideManager.skipToLastPage()
                    }
                    .foregroundColor(.white)
                    .padding(.leading)
                    .padding(.top)
                    
                    Spacer()
                }//Hstack
                Spacer()
                Text("Compare Schedules for any day, any time")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
               
                Image("Guide2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
//                    .padding(.bottom, 30)
                
                HStack{
                    Button(action: {
                        onboardGuideManager.previousPage()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .opacity(1.0)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                    }//button
                    Button(action: {
                        onboardGuideManager.nextPage()
                    }) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                            .opacity(1.0)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                    }//button
                }
            }
        } //Zstack
    }
}

struct OnboardGuide4: View {
    @EnvironmentObject var onboardGuideManager: OnboardGuideViewModel

    var body: some View {
        ZStack {
            LighterPurple
                .ignoresSafeArea()
            VStack {
                HStack {
                    Button("Skip") {
                        onboardGuideManager.skipToLastPage()
                    }
                    .foregroundColor(.white)
                    .padding(.leading)
                    .padding(.top)
                    
                    Spacer()
                }//Hstack
                Spacer()
                Text("Create tasks and to-dos for the room")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Image("Guide3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 30)
                
                
                HStack{
                    Button(action: {
                        onboardGuideManager.previousPage()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .opacity(1.0)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                    }//button
                    Button(action: {
                        onboardGuideManager.nextPage()
                    }) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                            .opacity(1.0)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                    }//button
                } // buttons hstack
            }
        } //Zstack
    }
}

struct OnboardGuide5: View {
    @EnvironmentObject var onboardGuideManager: OnboardGuideViewModel
    @EnvironmentObject var authModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            VStack {
                Spacer()
                VStack {
                    Text("Happy rooming with ")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    + Text("Roombee!")
                        .font(.largeTitle)
                        .foregroundColor(highlightYellow)
                }
                .multilineTextAlignment(.center)
                
                HStack{
                    Text("Go to Homepage")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                    Button(action: {
                        signUpWithEmailPassword() // Complete the onboarding process
                    }) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                            .opacity(1.0)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                    } //button
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        onboardGuideManager.previousPage() // Allow the user to go back if needed
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .opacity(1.0)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Text("Back to Guide")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                    
                    Spacer()
                }
            }
        }
    }
        private func signUpWithEmailPassword() {
            Task {
                if await authModel.signUpWithEmailPassword() == true {
                    DispatchQueue.main.async {
                        dismiss()
                    }
                }
                else {
                    print("Sign-In Failed: Invalid credentials.")
                }
            }
        }
}




//#Preview {
//    OnboardGuideView(viewModel: viewModel)
//}
