//
//  CalendarView.swift
//  roombee
//
//  Created by Adwait Ganguly on 10/7/23.
//

import SwiftUI
var ourPurple = hexStringToUIColor(hex: "#381e38")

class NewEventViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
}

struct NewEventView: View {
    @ObservedObject var viewModel: NewEventViewModel
    var onSave: (CalendarEvent) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $viewModel.title)
                DatePicker("Start Time", selection: $viewModel.startTime, displayedComponents: .hourAndMinute).datePickerStyle(WheelDatePickerStyle())
                DatePicker("End Time", selection: $viewModel.endTime, displayedComponents: .hourAndMinute).datePickerStyle(WheelDatePickerStyle())
            }
            .navigationTitle("New Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                      let newEvent = CalendarEvent(eventTitle: viewModel.title, startTime: viewModel.startTime, endTime: viewModel.endTime)
                        onSave(newEvent)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CalendarView: View {
    @EnvironmentObject var eventStore: EventStore
    var title: String
    @State private var showingAddEventSheet = false
    
    let date: Date = dateFrom(9, 5, 2023)
    
    //    @State var events: [Event] = [
    //        Event(startDate: dateFrom(9,5,2023,7,0), endDate: dateFrom(9,5,2023,8,0), title: "Interview"),
    //        Event(startDate: dateFrom(9,5,2023,9,0), endDate: dateFrom(9,5,2023,10,0), title: "Friend's Coming Over"),
    //        Event(startDate: dateFrom(9,5,2023,11,0), endDate: dateFrom(9,5,2023,12,00), title: "Project Meeting")
    //    ]
    
    let hourHeight = 50.0
    
    var body: some View {
        ZStack{
            toggleColor
            VStack(alignment: .leading) {
                
                // Date headline
                Text(title).bold()
                    .foregroundColor(toggleColor)
                
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(7..<18) { hour in
                                HStack {
                                    Text("\(hour)")
                                        .font(.caption)
                                        .frame(width: 20, alignment: .trailing)
                                    Color.gray
                                        .frame(height: 1)
                                }
                                .frame(height: hourHeight)
                            }
                        }
                        
                        ForEach(eventStore.events) { event in
                            eventCell(event)
                        }
                    }
                }
                Button("Add Event") {
                    showingAddEventSheet = true
                }
                .sheet(isPresented: $showingAddEventSheet) {
                    NewEventView(viewModel: NewEventViewModel()) { newEvent in
                        eventStore.addEvent(newEvent)
                    }
                }
                .padding()
                .background(Color(ourPurple))
                .foregroundColor(.white)
                .cornerRadius(8)
                .bold()
            }
            .padding()
        } //ZStack
        .cornerRadius(30)
    }//body
    
    func addNewEvent() {
        
    }
    
    func eventCell(_ event: CalendarEvent) -> some View {
        
        let duration = event.endTime.timeIntervalSince(event.startTime)
        let height = duration / 60 / 60 * hourHeight
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: event.startTime)
        let minute = calendar.component(.minute, from: event.startTime)
        let offset = Double(hour-7) * (hourHeight)
        //                      + Double(minute)/60 ) * hourHeight
        
        print(hour, minute, Double(hour-7) + Double(minute)/60 )
        
        return VStack(alignment: .leading) {
            Text(event.startTime.formatted(.dateTime.hour().minute()))
            Text(event.eventTitle).bold()
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(4)
        .frame(height: height, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.purple).opacity(0.5)
        )
        .padding(.trailing, 30)
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
