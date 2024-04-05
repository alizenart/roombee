//
//  SignUp.swift
//  roombee
//
//  Created by Alison Bai on 10/7/23.
//

import SwiftUI


struct SignUp: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    
    let backgroundColor = Color(red: 56 / 255, green: 30 / 255, blue: 56 / 255)
    
    let toggleColor = Color(red: 90 / 255, green: 85 / 255, blue: 77 / 255)
    
    var body: some View {
        
        NavigationView {
            ZStack{
                backgroundColor // Use the custom color here
                    .ignoresSafeArea()
//                Circle()
//                    .scale(1.7)
//                    .foregroundColor(.white.opacity(0.15))
//                Circle()
//                    .scale(1.35)
//                    .foregroundColor(.white)
                
                VStack{
                    if isSignUp {
                        Text("Sign Up")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                    } else {
                        Text("Login")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                            .foregroundColor(.init(red: 73/255, green: 73/255, blue: 73/255))
                    }
                    Text("Email").padding(.horizontal, -120)
                        .padding(.bottom, -100)
                        .foregroundColor(Color.gray)
                        .font(.system(size: 15))
                    TextField("", text: $email)
                        .padding()
                        .frame(width:250, height:50)
                        .overlay(Rectangle().frame(height: 1).padding(.top, 5), alignment: .bottomLeading)
                        .cornerRadius(10)
                        .padding(.bottom, 5)
                    
                    Text("Password").padding(.horizontal, -120)
                        .padding(.bottom, -100)
                        .padding(.top, 10)
                        .foregroundColor(Color.gray)
                        .font(.system(size: 15))
                    SecureField("", text: $password)
                        .padding()
                        .frame(width:250, height:50)
                        .overlay(Rectangle().frame(height: 1).padding(.top, 5), alignment: .bottomLeading)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                    
                    if(isSignUp){
                        NavigationLink(destination: Onboarding1()) {
                        Text("Sign Up").frame(width: 150, height: 30, alignment: .center)
                                                    .background(Color(red: 124 / 255, green: 93 / 255, blue: 138 / 255))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(10)
                                            }
                                        }
                                        else {
                                            NavigationLink(destination: HomepageView(calGrid: GridView(cal: CalendarView(title: "Me"), cal2: CalendarView(title: "Roomate")), yourStatus: StatusView(title: "Me:"), roomStatus: StatusView(title: "Roommate:")).environmentObject(EventStore())) {
                                                Text("Login").frame(width: 150, height: 30, alignment: .center)
                                                    .background(Color(red: 124 / 255, green: 93 / 255, blue: 138 / 255))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(10)
                                            }
                                        }
                    
                   

                    
                    

                    
                    Button(action: {
                        isSignUp.toggle()
                    }) {
                        Text(isSignUp ? "Already have an account? Login!" : "Don't have an account? Sign Up!")
                            .font(.system(size: 12))
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
        .navigationBarBackButtonHidden(true)
    }
    
    func signUp() {
        // Your sign-up logic
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}
