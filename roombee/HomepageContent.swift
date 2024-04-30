//
//  HomepageContent.swift
//  roombee
//
//  Created by Ziye Wang on 4/15/24.
//

import SwiftUI

struct HomepageContent: View {
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var selectedDateManager: SelectedDateManager


    var calGrid: GridView
    var yourStatus: StatusView
    var roomStatus: StatusView
    
    var schedCara: DatesCarousel {
        let dates = generateDates(startingFrom: selectedDateManager.SelectedDate, count: 7)
        return DatesCarousel(dates: dates, onDateSelected: { date in
            selectedDateManager.SelectedDate = date
        })
    }
    
    
    var body: some View {
        VStack {
            ZStack {
                backgroundColor // Use the custom color here
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        
                        Text("Roombee")
                            .font(.largeTitle)
                            .foregroundColor(ourOrange)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        
                        HStack(spacing: 20){
                            yourStatus
                            roomStatus
                        }.padding(.horizontal, 40)
                        //                        .padding(.bottom, 20)
                            .padding(.top, 20)
                        
                        schedCara.environmentObject(selectedDateManager)
                            .padding()
                        calGrid.padding([.leading, .trailing], 20)
                    }
                }
                        
            }
        }
    }
}


struct StatusView: View {
    @State private var isAsleep = false
    @State private var inRoom = false
    @State var title: String
    @State var canToggle: Bool
    
    var body: some View {
        let statusShape = RoundedRectangle(cornerRadius: 30)
        let bedIcon = Image(systemName: "bed.double.fill").foregroundColor(backgroundColor)
        let roomIcon = Image(systemName: "house")            .foregroundColor(backgroundColor)
        ZStack {
            statusShape
                .fill()
                .foregroundColor(toggleColor)
                .aspectRatio(1.0, contentMode: .fit)
            
            VStack {
                Text(title)
                    .foregroundColor(.black)
                    .bold()
                HStack{
                    Toggle(isOn: $isAsleep, label: {bedIcon})
                        .disabled(!canToggle)
                        .onChange(of: isAsleep) { isOn in
                            if isOn && canToggle{
                                backgroundColor = .black
                            }
                            else {
                                backgroundColor = Color(red: 56 / 255, green: 30 / 255, blue: 56 / 255)
                            }
                        }
                }.padding(.leading, 20).padding(.trailing, 20)
                HStack {
                    Toggle(isOn: $inRoom, label: {roomIcon})
                        .disabled(!canToggle)
                }.padding(.leading, 20).padding(.trailing, 20)
            }
        }
    }
}

struct DatesCarousel: View {
    @EnvironmentObject var selectedDateManager: SelectedDateManager
    var dates: [Date]
    var onDateSelected: (Date) -> Void
    
    var body: some View {
        VStack {
            Text("Schedules")
                .font(.system(size:25))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
            
            HStack {
                ForEach(dates, id: \.self) { date in DateToggle(date: date, today: Calendar.current.isDateInToday(date)) {
//                    onDateSelected(date)
                    selectedDateManager.SelectedDate = date
                }
                }
            }
        }
    }
}




func generateDates(startingFrom startDate: Date, count: Int) -> [Date] {
    var dates = [Date]()
    var current = startDate
    
    let calendar = Calendar.current
    let weekday = calendar.component(.weekday, from: current)
    let daysToGoBack = weekday - calendar.firstWeekday
    if let lastSunday = calendar.date(byAdding: .day, value: -daysToGoBack, to: current) {
        current = lastSunday
    }
    for day in 0..<count {
        if let date = calendar.date(byAdding: .day, value: day, to: current) {
            dates.append(date)
        }
    }
    return dates
}


struct DateToggle: View {
    @EnvironmentObject var selectedDateManager: SelectedDateManager
    var date : Date
    var today: Bool
    var onTapped: () -> Void
    
    var body: some View {
        Button(action: onTapped) {
            let statusShape = RoundedRectangle(cornerRadius: 10)
            ZStack {
                statusShape
                    .fill()
                    .foregroundColor(selectedDateManager.isDateSelected(date) ? highlightYellow : LighterPurple)  
                //                .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: 45, height: 60)
                
                VStack {
                    Text(monthName(from: date))
                        .foregroundColor(.white)
                        .bold()
                        .font(.system(size:15))
                    Text(MonthDay(from: date))
                        .foregroundColor(.white)
                        .bold()
                        .font(.system(size:20))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func monthName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM" // Format for abbreviated month name
        return formatter.string(from: date)
    }
    
    func MonthDay(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d" // Format for abbreviated month name
        return formatter.string(from: date)
    }
}



#Preview {
    HomepageContent(calGrid: GridView(cal: CalendarView(title: "Me")), yourStatus: StatusView(title: "Me:", canToggle: true), roomStatus: StatusView(title: "Roommate:", canToggle: false)).environmentObject(EventStore())
}
