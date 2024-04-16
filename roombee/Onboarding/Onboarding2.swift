//
//  Onboarding2.swift
//  roombee
//
//  Created by Ziye Wang on 4/3/24.
//

import SwiftUI

struct Onboarding2: View {
    
    let backgroundColor = Color(red: 56 / 255, green: 30 / 255, blue: 56 / 255)
    
    let toggleColor = Color(red: 230 / 255, green: 217 / 255, blue: 197 / 255)
    
    let textColor = Color(red: 73/255, green: 73/255, blue: 73/255)
    
    
    var body: some View {
        //        NavigationView{
        GeometryReader { geometry in
            
            ZStack{
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 10){
                    Spacer().frame(height: geometry.size.height / 4) // Adjust this to change the starting position
                    VStack{
                        Text("Already Have a Room with us?")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                            .foregroundColor(.init(textColor))
                        NavigationLink(destination: Onboarding3_CreateRoom()){
                            Text("Create Room")
                                .font(.system(size : 25, weight: .bold))
                                .frame(width: 225, height: 75, alignment: .center)
                                .background(Color(red: 124 / 255, green: 93 / 255, blue: 138 / 255))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: Onboarding3_joinExisting()){
                            Text("Join Room")
                                .font(.system(size : 25, weight: .bold))
                                .frame(width: 225, height: 75, alignment: .center)
                                .background(Color(red: 124 / 255, green: 93 / 255, blue: 138 / 255))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        
                    } //vstack (mini)
                    .padding()
                    .background(Rectangle()
                        .foregroundColor(.init(toggleColor))
                        .cornerRadius(15)
                        .shadow(radius: 15))
                    .padding()
                    
                    
                    
                    Spacer()
                    
                    // Nav Buttons
                    //                        NavigationLink(destination: Onboarding1()) {
                    //                            Text("Go Back")
                    //                                .font(.system(size : 20, weight: .bold))
                    //                                .frame(width: 125, height: 40, alignment: .center)
                    //                                .background(Color(red: 162 / 255, green: 154 / 255, blue: 165 / 255))
                    //                                .foregroundColor(.white)
                    //                                .cornerRadius(10)
                    //                        }//button
                    //                        .padding(.top, 10)
                    
                }//vstack (big)
            }//zstack
            
            
            
        } //geometry reader
        //            .navigationBarHidden(true)
        //            .navigationBarBackButtonHidden(true)
        //        }// navigationview
        
    } //body
    
    
    func GoBack() {
        //going back to signup/login page
    }
    
    func CreateRoom() {
        //create room logic
    }
    
    func JoinRoom() {
        //join room logic
    }
    
} //Onboarding2



struct Onboarding2_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding2()
    }
}
