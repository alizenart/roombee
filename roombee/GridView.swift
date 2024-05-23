//
//  GridView.swift
//  roombee
//
//  Created by Adwait Ganguly on 10/7/23.
//

import SwiftUI

struct GridView: View {
    @EnvironmentObject var selectedDateManager: SelectedDateManager

    var cal: CalendarView
    
    var body: some View {
//        let date = Date()
        VStack{
            HStack {
                Text(selectedDateManager.SelectedDate.formatted(.dateTime.day().month()))
                    .bold()
                Text(selectedDateManager.SelectedDate.formatted(.dateTime.year()))
            }
            .foregroundColor(.white)
            .font(.title)
            Text(selectedDateManager.SelectedDate.formatted(.dateTime.weekday(.wide)))
                .foregroundColor(.white)
            
            Grid() {
                GridRow {
                    cal
                        .frame(height: 650)
                        .clipped()
                }
            }
        }
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(cal: CalendarView(title: "Me"))
    }
}
