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
    @Published var dateEvent: Date = Date()
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    
    init(selectedDate: Date) {
        print("NewEventViewModel initialized with date: \(selectedDate)")
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
    @EnvironmentObject var auth: AuthenticationViewModel
    var onSave: (CalendarEvent) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var errorMessage: String? = nil
    
    var body: some View {

        ZStack {
            creamColor
            NavigationView {
                Form {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    TextField("Name of Event", text: $viewModel.title)
                        .frame(width: 300, height: 40)
                        .font(.system(size: 20))
                        .onChange(of: viewModel.title) { newValue in
                        }
                    
                    Section(header: Text("Date").font(.system(size: 20))) {
                        DatePicker("Event Date", selection: $viewModel.dateEvent, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                        
                    }
                    Section(header: Text("Start & End Time").font(.system(size: 20))){
                        DatePicker("Start Time", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .onChange(of: viewModel.startTime) { newStartTime in
                                // Ensure end time remains valid, and update only if necessary
                                if viewModel.endTime <= newStartTime {
                                    viewModel.endTime = Calendar.current.date(byAdding: .hour, value: 1, to: newStartTime) ?? newStartTime
                                }
                            }
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
                            if let userId = auth.user_id {
                                let calendar = Calendar.current
                                
                                // Combine the selected date with the time component of startTime and endTime
                                let selectedDate = viewModel.dateEvent
                                let startComponents = calendar.dateComponents([.hour, .minute], from: viewModel.startTime)
                                let endComponents = calendar.dateComponents([.hour, .minute], from: viewModel.endTime)
                                
                                // Create new start and end dates with the selected date
                                let startTime = calendar.date(bySettingHour: startComponents.hour!, minute: startComponents.minute!, second: 0, of: selectedDate) ?? selectedDate
                                let endTime = calendar.date(bySettingHour: endComponents.hour!, minute: endComponents.minute!, second: 0, of: selectedDate) ?? selectedDate
                                
                                let newEvent = CalendarEvent(user_id: userId, eventTitle: viewModel.title, startTime: startTime, endTime: endTime)
                                onSave(newEvent)
                                NotificationService.shared.scheduleNotification(for: newEvent)
                                dismiss()
                            } else {
                                errorMessage = "No user information found."
                            }
                        }

                        .foregroundColor(backgroundColor)
                    } // ToolbarItem
                } // toolbar

            }
        }
    }
}


struct CalendarView: View {
    @StateObject private var newEventViewModel = NewEventViewModel(selectedDate: Date())
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var selectedDateManager: SelectedDateManager
    @EnvironmentObject var auth: AuthenticationViewModel
    @State private var timer:Timer?
    @State private var deletedEvents: Set<String> = []
    @State private var events: [CalendarEvent] = []


    var title: String
    @State private var showingAddEventSheet = false
    @State private var initialScrollOffset: CGFloat?
    @State private var skipFilter = false
    
    @State private var errorMessage: String? = nil
    
    
    let hourHeight = 50.0
    let maxEventWidth: CGFloat = 250.0
    
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
                            
                            ForEach(groupedEvents(), id: \.self) { group in
                                ForEach(group, id: \.id) { event in
                                    let eventWidth = maxEventWidth - CGFloat(group.firstIndex(of: event)! * 10)
                                    eventCell(event, width: eventWidth)
                                        .frame(alignment: .trailing)
                                    //                                        .padding(1)
                                }
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
        .onAppear {
            getNewEvents()
            startTimer()
        }
        .alert(isPresented: .constant(errorMessage != nil), content: {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK")) {
                    errorMessage = nil // Clear the error message when the alert is dismissed
                }
            )
        })
        
    }
    private func startTimer() {
            stopTimer()  // Ensure no timer is already running
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                getNewEvents()
            }
        }
    
    private func stopTimer() {
        timer?.invalidate()
                timer = nil
    }
    private func getNewEvents() {
        guard let userId = auth.user_id else {
            errorMessage = "Error: No user information found."
            return
        }
        
        eventStore.getAllEvents(user_id: userId, roommate_id: auth.roommate_id)
        
        if skipFilter {
            skipFilter = false
            return
        }
        
        let all_events = eventStore.userEvents + eventStore.roommateEvents
        events = events.filter { old_event in
            all_events.contains(old_event)
        }
        
        let new_events = all_events.filter { new_event in
            !events.contains(where: { $0.id.uuidString == new_event.id.uuidString })
        }
        
        events.append(contentsOf: new_events)
    }

    
    var filteredEvents: [CalendarEvent] {
        let selectedDate = selectedDateManager.SelectedDate
        let calendar = Calendar.current
        
        return events.filter { event in
            let eventDate = calendar.startOfDay(for: event.startTime)
            let selectedDay = calendar.startOfDay(for: selectedDate)
            return eventDate == selectedDay
        }
    }
    
    func hourView(_ hour: Int) -> some View {
        let hourLabel: String
        if hour == 0 {
            hourLabel = "12 AM"
        } else if hour == 12 {
            hourLabel = "12 PM"
        } else if hour < 12 {
            hourLabel = "\(hour) AM"
        } else {
            hourLabel = "\(hour - 12) PM"
        }
        
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
        .sheet(isPresented: $showingAddEventSheet, onDismiss: {
            // Resume the timer when the NewEventView is dismissed
            startTimer()
        }) {// Move this into a closure to ensure it doesn’t return a View
            NewEventView(viewModel: newEventViewModel) { newEvent in
                if let userId = auth.user_id {
                    events.append(newEvent)
                    eventStore.addEvent(user_id: userId, newEvent)
                    skipFilter = true
                } else {
                    // Handle the case where user_id is nil (e.g., show an error message)
                    errorMessage = "Error: No user information found."
                }
            }
            .onAppear {
                stopTimer()
            }
        }
        .padding()
    }
    
    func eventCell(_ event: CalendarEvent, width: CGFloat) -> some View {
        let isUserEvent = eventStore.userEvents.contains(event)
        let backgroundColor = isUserEvent ? LighterPurple : highlightYellow // Different color for roommate's events

        let duration = event.endTime.timeIntervalSince(event.startTime)
        let height = duration / 60 / 60 * hourHeight
        
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: event.startTime)
        let startMinute = calendar.component(.minute, from: event.startTime)
        let offsetY = (Double(startHour) + Double(startMinute) / 60.0) * hourHeight
        
        return VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(event.startTime.formatted(.dateTime.hour().minute()))
                        .foregroundColor(.white)
                    Text(event.eventTitle).bold()
                        .foregroundColor(.white)
                    
                }
                Spacer()
                
                Button(action: {
                    skipFilter = true
                    deletedEvents.insert(event.id.uuidString)
                    events.removeAll(where: {$0.id == event.id})
                    eventStore.deleteEvent(eventId: event.id.uuidString) // Ensure this matches the expected string format
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                }
                .disabled(backgroundColor == highlightYellow)
            }
            .font(.caption)
            .frame(width: width, alignment: .topLeading) // Align to the right
            .padding(4)
            .frame(height: height, alignment: .top)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(toggleColor, lineWidth: 2))
            .padding(.leading, 60) // Add padding on the right
            .offset(y: offsetY + 24)
            .offset(x: maxEventWidth - width) //Offset the cell by the difference between maxEventWidth and current width
        }
    }

    
    func groupedEvents() -> [[CalendarEvent]] {
        var groups: [[CalendarEvent]] = []
        // let sortedEvents = eventStore.events.sorted { $0.startTime <= $1.startTime }
        let sortedEvents = filteredEvents.sorted { $0.startTime < $1.startTime }
        
        for event in sortedEvents {
            var addedToGroup = false
            for group in groups.indices {
                if groups[group].contains(where: { $0.startTime < event.endTime && $0.endTime > event.startTime }) {
                    groups[group].append(event)
                    addedToGroup = true
                    break
                }
            }
            if !addedToGroup {
                groups.append([event])
            }
        }
        
        // Sort each group by duration (longest first)
        for i in groups.indices {
            groups[i].sort { ($0.endTime.timeIntervalSince($0.startTime)) > ($1.endTime.timeIntervalSince($1.startTime)) }
        }
        
        return groups
    }
}


func dateFrom(_ day: Int, _ month: Int, _ year: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
    let calendar = Calendar.current
    let dateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
    return calendar.date(from: dateComponents) ?? .now
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

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(title: String()).environmentObject(EventStore())
    }
}
