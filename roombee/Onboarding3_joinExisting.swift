//
//  Onboarding3-joinExisting.swift
//  roombee
//
//  Created by Ziye Wang on 4/3/24.
//

import SwiftUI


struct Onboarding3_joinExisting: View {
    
    @State private var HiveCode = ""
    
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
                        
                        TextField("", text: $HiveCode)
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

                            

                        NavigationLink(destination: HomepageView(calGrid: GridView(cal: CalendarView(title: "Me"), cal2: CalendarView(title: "Roomate")), yourStatus: StatusView(title: "Me:"), roomStatus: StatusView(title: "Roommate:")).environmentObject(EventStore())){
                            Text("Let's Go!")
                                .font(.system(size : 25, weight: .bold))
                                .frame(width: 175, height: 60, alignment: .center)
                                .background(Color(red: 124 / 255, green: 93 / 255, blue: 138 / 255))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
//                        Button(action: GoBack) {
//                            Text("Go Back")
//                                .font(.system(size : 20, weight: .bold))
//                                .frame(width: 125, height: 40, alignment: .center)
//                                .background(Color(red: 162 / 255, green: 154 / 255, blue: 165 / 255))
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                        }//button
//                        .padding(.top, 10)
                        
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
            
        } //body
    
    
    func GoBack() {
        //going back to signup/login page
    }
    
    func GoToHome() {
        //create go to home logic
    }
    
    func JoinRoom() {
        //join room logic
    }
    
} //Onboarding2



struct Onboarding3_joinExisting_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding3_joinExisting()
    }
}
