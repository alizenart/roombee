//
//  Onboarding3-joinExisting.swift
//  roombee
//
//  Created by Ziye Wang on 4/3/24.
//

import SwiftUI


struct Onboarding3_joinExisting: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var onboardGuideManager: OnboardGuideViewModel
    @State private var showOnboardingGuide = false // State to control the transition
    
    
    let backgroundColor = Color(red: 56 / 255, green: 30 / 255, blue: 56 / 255)
    
    let toggleColor = Color(red: 230 / 255, green: 217 / 255, blue: 197 / 255)
    
    let textColor = Color(red: 73/255, green: 73/255, blue: 73/255)
    
    let strokeColor = Color(red: 190/255, green: 172/255, blue: 136/255)
    
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack{
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 10){
                    VStack{
                        Text("Join")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.init(textColor))
                            .padding(.bottom, 10)
                            .padding(.top, 20)
                        Text("Enter Hive Code:")
                            .font(.system(size: 20, weight : .bold))
                            .foregroundColor(.init(textColor))
                        
                        TextField("", text: $authViewModel.hive_code)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(width: 225, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(strokeColor, lineWidth: 2)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                                    .opacity(0.5)
                            )
                            .cornerRadius(10)
                            .padding(.bottom, 10)
                        
                        Button(action: {
                            authViewModel.skipCreateOrJoin = true
                            showOnboardingGuide = true 
                        }) {                            
                            Text("Let's Go!")
                                .font(.system(size : 25, weight: .bold))
                                .frame(width: 175, height: 60, alignment: .center)
                                .background(Color(red: 124 / 255, green: 93 / 255, blue: 138 / 255))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .alert(isPresented: $authViewModel.addUserError) {
                            Alert(
                                title: Text("Error"),
                                message: Text(authViewModel.addUserErrorMessage),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                        
                    } //vstack (mini)
                    .padding()
                    .background(Rectangle()
                        .foregroundColor(.init(toggleColor))
                        .cornerRadius(15)
                        .shadow(radius: 15))
                    .padding()
                } // vstack
                .sheet(isPresented: $showOnboardingGuide) {
//                    OnboardGuideView()
//                        .environmentObject(authViewModel)
//                        .environmentObject(onboardGuideManager) //commented out due to changes and this now causes errors
                } //sheet
                
                
            }//zstack
            
            
            
        } //geometry reader
        
    } //body
}



struct Onboarding3_joinExisting_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding3_joinExisting().environmentObject(AuthenticationViewModel())
    }
}
