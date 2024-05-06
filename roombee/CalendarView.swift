//
//  CalendarView.swift
//  roombee
//
//  Created by Adwait Ganguly on 10/7/23.
//

import SwiftUI

struct CalendarEvent: Identifiable {
    let id = UUID()
    var dateEvent: Date
    var startTimeCal: Date
    var endTimeCal: Date
    var title: String
}

var ourPurple = hexStringToUIColor(hex: "#381e38")

class NewEventViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var dateEvent: Date = Date()
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    
    init(selectedDate: Date) {
        let calendar = Calendar.current
        self.dateEvent = calendar.startOfDay(for: selectedDate)
        self.startTime = calendar.startOfDay(for: selectedDate)
        self.endTime = calendar.date(byAdding: .hour, value: 1, to: startTime) ?? startTime
    }
}



//the popup when you press the plus button
struct NewEventView: View {
    @ObservedObject var viewModel: NewEventViewModel
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var selectedDateManager: SelectedDateManager
    var onSave: (CalendarEvent) -> Void
    @Environment(\.dismiss) var dismiss
    

    
    var body: some View {
        ZStack {
            creamColor
            NavigationView {
                Form {
                    TextField("Name of Event", text: $viewModel.title)
                        .frame(width: 300, height: 40)
                        .font(.system(size: 20))
                    
                    Section(header: Text("Date").font(.system(size: 20))) {
                        DatePicker("Event Date", selection: $viewModel.dateEvent, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                    Section(header: Text("Start & End Time").font(.system(size: 20))){
                        DatePicker("Start Time", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                        DatePicker("End Time", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(backgroundColor)
                .background(creamColor)
                .navigationTitle("New Event")
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(backgroundColor)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            let newEvent = CalendarEvent(dateEvent: viewModel.dateEvent, startTimeCal: viewModel.startTime, endTimeCal: viewModel.endTime, title: viewModel.title)
                            eventStore.addEvent(newEvent)
                            onSave(newEvent)
                            dismiss()
                        }
                        .foregroundColor(backgroundColor)
                    } // ToolbarItem
                } // toolbar

            }
        }
    }
}


struct CalendarView: View {
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var selectedDateManager: SelectedDateManager
    
    var title: String
    @State private var showingAddEventSheet = false
    @State private var initialScrollOffset: CGFloat?

    
    let hourHeight = 50.0
    
    var body: some View {
        ZStack{
            creamColor
            VStack(alignment: .leading) {
                
                // Date headline
                Text(title).bold()
                    .foregroundColor(toggleColor)
                
                
                ScrollView {
                    ScrollViewReader {value in
                        
                        ZStack(alignment: .topLeading) {
                            
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(0..<24, id: \.self) { hour in
                                    hourView(hour)
                                }
                            }
                            
                            ForEach(eventStore.events) { event in
                                eventCell(event)
                            }
                        }
                        .onAppear {
                            // Scroll to 7 AM initially
                            value.scrollTo(7, anchor: .top)
                        }
                    }
                    
                }
                addButton()
            }
            .padding()
        } //ZStack
        .cornerRadius(30)
    }//body
    func hourView(_ hour: Int) -> some View {
        let hourLabel = hour == 0 ? "12 AM" : (hour <= 12 ? "\(hour) AM" : "\(hour - 12) PM")
        return HStack {
            Text(hourLabel)
                .font(.caption)
                .frame(width: 40, alignment: .trailing)
            Color.gray.frame(height: 1)
        }
        .frame(height: hourHeight)
        .id(hour)
    }
    
    func addButton() -> some View {
        Button(action: {
            showingAddEventSheet = true
        }) {
            ZStack {
                hexagonShape()
                    .frame(width: 50, height: 60)
                    .foregroundColor(backgroundColor)
                
                Text("+")
                    .padding(.bottom, 5)
                    .font(.system(size: 45))
                    .foregroundColor(.white)
                    .bold()
            }
        }
        .sheet(isPresented: $showingAddEventSheet) {
            NewEventView(viewModel: NewEventViewModel(selectedDate: selectedDateManager.SelectedDate)) { newEvent in
                eventStore.addEvent(newEvent)
            }
        }
        .padding()
    }
//
//    private func filteredEvents(for date: Date) -> [CalendarEvent] {
//        eventStore.events.filter { event in
//            Calendar.current.isDate(event.startDate, inSameDayAs: date)
//        }
//    }
    
    func eventCell(_ event: CalendarEvent) -> some View {
        
        let duration = event.endTimeCal.timeIntervalSince(event.startTimeCal)
        let height = duration / 60 / 60 * hourHeight
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: event.startTimeCal)
        let minute = calendar.component(.minute, from: event.startTimeCal)
        let offset = Double(hour-7) * (hourHeight)
        //                      + Double(minute)/60 ) * hourHeight
        
        print(hour, minute, Double(hour-7) + Double(minute)/60 )
        
        return VStack(alignment: .leading) {
            Text(event.startTimeCal.formatted(.dateTime.hour().minute()))
            Text(event.title).bold()
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(4)
        .frame(height: height, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(LighterPurple)
        )
        .padding(.trailing, 30)
        .padding(.leading, 50)

        .offset(x: 30, y: offset + 24)
    }
}


func dateFrom(_ day: Int, _ month: Int, _ year: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
    let calendar = Calendar.current
    let dateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
    return calendar.date(from: dateComponents) ?? .now
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(title: String()).environmentObject(EventStore())
    }
}
