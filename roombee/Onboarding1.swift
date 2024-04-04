//
//  Onboarding1.swift
//  roombee
//
//  Created by Ziye Wang on 4/3/24.
//

import SwiftUI

struct Onboarding1: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birthDate = Date()
    @State private var gender = ""
    
    @State private var ShowNextView = false
    
    let backgroundColor = Color(red: 56 / 255, green: 30 / 255, blue: 56 / 255)
    
    let toggleColor = Color(red: 230 / 255, green: 217 / 255, blue: 197 / 255)
    
    let textColor = Color(red: 73/255, green: 73/255, blue: 73/255)
    
    let genderOptions = ["Female", "Male", "Other"]
    
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                
                ZStack{
                    backgroundColor
                        .ignoresSafeArea()
                    // everything vstack
                    VStack{
                        Spacer().frame(height: geometry.size.height / 5) // Adjust this to change the starting position
                        
                        
                        //vstack for the toggle
                        VStack(spacing: 10){
                            Text("Create your profile")
                                .font(.largeTitle)
                                .bold()
                                .padding()
                                .foregroundColor(.init(textColor))
                            TextField("First Name", text: $firstName)
                                .padding()
                                .frame(width:250, height:50)
                                .overlay(Rectangle().frame(height: 1).padding(.top, 5), alignment: .bottomLeading)
                                .cornerRadius(10)
                            
                            TextField("Last Name", text: $lastName)
                                .padding()
                                .frame(width:250, height:50)
                                .overlay(Rectangle().frame(height: 1).padding(.top, 5), alignment: .bottomLeading)
                                .cornerRadius(10)
                                .padding()
                            
                            DatePicker("Birthday", selection: $birthDate,
                                       in: ...Date(), // Limits the selectable dates up to today
                                       displayedComponents: .date // Shows only the date picker
                            )
                            .padding()
                            .frame(width:250, height:50)
                            
                            Picker("Gender", selection: $gender) {
                                ForEach(genderOptions, id: \.self) { gender in
                                    Text(gender).tag(gender)
                                }
                            }
                            .pickerStyle(MenuPickerStyle()) // Use MenuPickerStyle for a dropdown effect
                            .frame(width:250, height:50)
                            //                        .padding()
                            
                            
                        }
                        .padding()
                        .background(Rectangle()
                            .foregroundColor(.init(toggleColor))
                            .cornerRadius(15)
                            .shadow(radius: 15))
                        .padding()
                        
                        Spacer()
                        
                        //Buttons
                        NavigationLink(destination: Onboarding2()) {
                            Text("Next")
                                .font(.system(size : 30, weight: .bold))
                                .frame(width: 150, height: 50, alignment: .center)
                                .background(Color(red: 124 / 255, green: 93 / 255, blue: 138 / 255))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            
                        }
                        .navigationDestination(isPresented: $ShowNextView) {
                            Onboarding2()
                        }
                        
                        
                        Button(action: GoBack) {
                            Text("Go Back")
                                .font(.system(size : 20, weight: .bold))
                                .frame(width: 125, height: 40, alignment: .center)
                                .background(Color(red: 162 / 255, green: 154 / 255, blue: 165 / 255))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    
                    
                }
                .navigationBarHidden(true)
                
            }
            
        }
    }
    func NextStep() {
        //connecting logic
        ShowNextView = true
    }
    
    func GoBack() {
        //going back to signup/login page
    }
}

    


struct Onboarding1_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding1()
    }
}
