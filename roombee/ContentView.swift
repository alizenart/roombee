//
//  ContentView.swift
//  roombee
//
//  Created by Adwait Ganguly on 10/7/23.
//

import SwiftUI

struct ContentView: View {
  @State private var isTimerDone = false
  var ourPurple = hexStringToUIColor(hex: "#381e38")
  var body: some View {
      if isTimerDone {
          NavigationView {
              SignUp() // go to signup view
          }
      }
      else {
          ZStack{
              Color(ourPurple).ignoresSafeArea()
              VStack {
                  Text("Roombee").font(.largeTitle).bold().foregroundColor(.yellow)
              }
              .onAppear() {
                  Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                      // Set the state variable to true after 2 seconds
                      isTimerDone = true
                  }
              }
              .padding()
          }
      }
  }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
