//
//  Hexagon.swift
//  roombee
//
//  Created by Ziye Wang on 4/29/24.
//

import SwiftUI

struct Hexagon: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        NavigationView {
            VStack {
                hexagonShape()
                    .foregroundColor(.black)
                    .frame(width: 150, height: 150)
            }
        }
    }
}

struct hexagonShape: Shape{
    func path(in rect: CGRect) -> Path{
        
        var path = Path()
        
        //start top middle then go 5 more points in a counterclockwise
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        
        path.addLine(to: CGPoint(x: rect.minX , y: rect.maxY*(1/4)))
        path.addLine(to: CGPoint(x: rect.minX , y: rect.maxY*(3/4)))
        
        path.addLine(to: CGPoint(x: rect.midX , y: rect.maxY))
        
        path.addLine(to: CGPoint(x: rect.maxX , y: rect.maxY*(3/4)))

        
        path.addLine(to: CGPoint(x: rect.maxX , y: rect.maxY*(1/4)))
        
        path.addLine(to: CGPoint(x: rect.midX , y: rect.minY))
        
        return path
    }
}

#Preview {
    Hexagon()
}
