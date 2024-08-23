//
//  Onboarding2.swift
//  roombee
//
//  Created by Ziye Wang on 4/3/24.
//

import SwiftUI

struct Onboarding2: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var onboardGuideManager: OnboardGuideViewModel

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
                        NavigationLink(destination: Onboarding3_CreateRoom().environmentObject(onboardGuideManager)){
                            Text("Create Room")
                                .font(.system(size : 25, weight: .bold))
                                .frame(width: 225, height: 75, alignment: .center)
                                .background(Color(red: 124 / 255, green: 93 / 255, blue: 138 / 255))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: Onboarding3_joinExisting().environmentObject(onboardGuideManager)){
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
                }//vstack (big)
            }//zstack
            
            
            
        } //geometry reader
        
    } //body
    
} //Onboarding2



struct Onboarding2_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding2().environmentObject(AuthenticationViewModel())
    }
}
