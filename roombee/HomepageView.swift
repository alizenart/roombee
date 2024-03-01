//
//  HomepageView.swift
//  roombee
//
//  Created by Adwait Ganguly on 10/7/23.
//

import SwiftUI

struct HomepageView: View {
    @EnvironmentObject var eventStore: EventStore
    var ourPurple = hexstringToUIColor(hex: "#381e38")
    var calGrid: GridView
    var yourStatus: StatusView
    var roomStatus: StatusView
    
//    let content = ContentView
//    var hexFunc = content.hexStringToUIColor(hex: "#381e38")
    
    var body: some View {
        VStack {
            Text("Roombee").font(.title).bold()
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.purple, .white]), startPoint: .bottom, endPoint: .center).ignoresSafeArea()
                VStack {
                    HStack(spacing: 10){
                        yourStatus
                        roomStatus
                    }.padding(.horizontal, 40).padding(.bottom, 40)
                    calGrid
                }
            }
        }
    }
}

struct StatusView: View {
    @State private var isAsleep = false
    @State private var inRoom = false
    @State var title: String
    
    var body: some View {
        let statusShape = RoundedRectangle(cornerRadius: 20)
        let bedIcon = Image(systemName: "bed.double.fill").foregroundColor(.white)
        let roomIcon = Image(systemName: "house").foregroundColor(.white)
        ZStack {
            statusShape
                .fill()
                .foregroundColor(.purple)
                .aspectRatio(1.0, contentMode: .fit)
            
            VStack {
                Text(title)
                    .foregroundColor(.white)
                    .bold()
                HStack{
                    Toggle(isOn: $isAsleep, label: {bedIcon})
                }.padding(.leading, 10).padding(.trailing, 10)
                HStack {
                    Toggle(isOn: $inRoom, label: {roomIcon})
                }.padding(.leading, 10).padding(.trailing, 10)
            }
        }
        
        
        
    }
}

func hexstringToUIColor (hex:String) -> UIColor {
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

struct HomepageView_Previews: PreviewProvider {
    static var previews: some View {
      HomepageView(calGrid: GridView(cal: CalendarView(title: "Me"), cal2: CalendarView(title: "Roomate")), yourStatus: StatusView(title: "Me:"), roomStatus: StatusView(title: "Roommate:")).environmentObject(EventStore())
    }
}

