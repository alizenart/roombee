//
//  HomepageView.swift
//  roombee
//
//  Created by Adwait Ganguly on 10/7/23.
//

import SwiftUI


var backgroundColor = Color(red: 56 / 255, green: 30 / 255, blue: 56 / 255)

let toggleColor = Color(red: 230 / 255, green: 217 / 255, blue: 197 / 255)

let ourOrange = Color(red: 221 / 255, green: 132 / 255, blue: 67 / 255)

let LighterPurple = Color(red: 124 / 255, green: 93 / 255, blue: 138 / 255)

let date = Date()
let formatter = DateFormatter()

struct HomepageView: View {
    @EnvironmentObject var eventStore: EventStore
    var calGrid: GridView
    var yourStatus: StatusView
    var roomStatus: StatusView
    
    //new variables -z
    var schedCara: DatesCarousel {
        let dates = generateDates(startingFrom: Date(), count: 7) // Adjust parameters as needed
        return DatesCarousel(dates: dates, onDateSelected: { _ in }, selectedDate: .constant(Date()))
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
                
                schedCara
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
        let bedIcon = Image(systemName: "bed.double.fill").foregroundColor(.white)
        let roomIcon = Image(systemName: "house").foregroundColor(.white)
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



struct DatesCarousel:View {
    var dates: [Date] // Array of dates
    var onDateSelected: (Date)-> Void
    @Binding var selectedDate: Date

    var body: some View {
        ZStack {
            VStack{
                Text("Schedules")
                    .font(.system(size:25))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 30)
                    .padding(.leading, -170)
                HStack{
                    ForEach(dates, id: \.self) { date in
                        DateToggle(date: date, today: Calendar.current.isDateInToday(date)) {
                            onDateSelected(date)
                        }
                    }
                }
            }
        }
    }
}

func generateDates(startingFrom startDate: Date, count: Int) -> [Date] {
    var dates = [Date]()
    for day in 0..<count {
        if let date = Calendar.current.date(byAdding: .day, value: day, to: startDate) {
            dates.append(date)
        }
    }
    return dates
}


struct DateToggle: View {
//    var Month
    var date : Date
    var today: Bool
    var onTapped: () -> Void  // Closure to be called when the toggle is tapped

    var body: some View {
        Button(action: onTapped) {
            let statusShape = RoundedRectangle(cornerRadius: 10)
            ZStack {
                statusShape
                    .fill()
                    .foregroundColor(LighterPurple)
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


struct HomepageView_Previews: PreviewProvider {
    static var previews: some View {
      HomepageView(calGrid: GridView(cal: CalendarView(title: "Me")), yourStatus: StatusView(title: "Me:", canToggle: true), roomStatus: StatusView(title: "Roommate:", canToggle: false)).environmentObject(EventStore())
    }
}

