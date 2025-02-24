//
//  CalendarView.swift
//  roombee
//
//  Created by Adwait Ganguly on 10/7/23.
//

import SwiftUI
import UIKit
import Mixpanel

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
    @State private var isMultidayEvent: Bool = false
    @State private var showEndTimeWarning: Bool = false // State for warning

    var body: some View {
        ZStack {
            creamColor
                .onTapGesture {
                    // This will dismiss the keyboard when you tap anywhere on the screen
                    UIApplication.shared.dismissKeyboard()
                }
            NavigationView {
                Form {
                    VStack {
//                        if let errorMessage = errorMessage {
//                            Text(errorMessage)
//                                .foregroundColor(.red)
//                        }
                        
                        TextField("Name of Event", text: $viewModel.title)
                            .frame(width: 300, height: 40)
                            .font(.system(size: 20))
                        
                        // Event Date Selection
//                        Section(header: Text("Date")
//                            .font(.system(size: 20, weight: .bold))
//                            .frame(maxWidth: .infinity, alignment: .leading)) 
                        
                        Section {
//                            Text("Date") // Custom label for date
//                                .font(.system(size: 20, weight: .bold))
//                                .frame(maxWidth: .infinity, alignment: .leading)
                            DatePicker("Event Date", selection: $viewModel.dateEvent, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
//                                .onChange(of: viewModel.dateEvent) { newDate in
//                                    // Adjust startTime and endTime to match the selected date
//                                    let calendar = Calendar.current
//                                    viewModel.startTime = calendar.date(bySettingHour: calendar.component(.hour, from: viewModel.startTime),
//                                        minute: calendar.component(.minute, from: viewModel.startTime),
//                                        second: 0, of: newDate) ?? newDate
//                                    viewModel.endTime = calendar.date(bySettingHour: calendar.component(.hour, from: viewModel.endTime),
//                                        minute: calendar.component(.minute, from: viewModel.endTime),
//                                        second: 0, of: newDate) ?? newDate
//                                    print("Updated dateEvent: \(viewModel.dateEvent)")
//                                    print("Updated startTime: \(viewModel.startTime)")
//                                    print("Updated endTime: \(viewModel.endTime)")
//                                    checkAndFixEndTime()
//                                    updateMultidayEventStatus()
//                                }
                                .onChange(of: viewModel.dateEvent) { newDate in
                                    let calendar = Calendar.current
                                    let newStartHour = calendar.component(.hour, from: viewModel.startTime)
                                    let newStartMinute = calendar.component(.minute, from: viewModel.startTime)
                                    
                                    let newEndHour = calendar.component(.hour, from: viewModel.endTime)
                                    let newEndMinute = calendar.component(.minute, from: viewModel.endTime)
                                    
                                    viewModel.startTime = calendar.date(bySettingHour: newStartHour, minute: newStartMinute, second: 0, of: newDate) ?? newDate
                                    viewModel.endTime = calendar.date(bySettingHour: newEndHour, minute: newEndMinute, second: 0, of: newDate) ?? newDate
                                    
                                    checkAndFixEndTime()
                                    updateMultidayEventStatus()
                                }

                        }
                        .padding(.bottom)
                        
                        // Start & End Time Section
                        Section {
                            Text("Start Time") // Custom label for start time
                                .font(.system(size: 20, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            DatePicker("", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(WheelDatePickerStyle())
                                .onChange(of: viewModel.startTime) { newStartTime in
                                    // Ensure endTime remains valid, and update only if necessary
                                    if viewModel.endTime <= newStartTime {
                                        viewModel.endTime = Calendar.current.date(byAdding: .hour, value: 1, to: newStartTime) ?? newStartTime
                                    }
                                    // Ensure that the endTime remains on the same date
                                    viewModel.endTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: viewModel.endTime),
                                            minute: Calendar.current.component(.minute, from: viewModel.endTime),
                                            second: 0, of: viewModel.dateEvent) ?? newStartTime
                                    print("Updated startTime: \(viewModel.startTime)")
                                    print("Adjusted endTime: \(viewModel.endTime)")
                                    checkAndFixEndTime()
                                    updateMultidayEventStatus()
                                }

                            Text("End Time") // Custom label for end time
                                .font(.system(size: 20, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            DatePicker("    ", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(WheelDatePickerStyle())
                                .onChange(of: viewModel.endTime) { newEndTime in
                                    print("Updated endTime: \(newEndTime)")
                                    checkAndFixEndTime()
                                    updateMultidayEventStatus()
                                }
                            

                            // Show warning if the end time was reset due to multiday event
                            if showEndTimeWarning {
                                Text("No multiday time allowed.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.top, 5)
                            }
                        }//section

                        // Error message for multiday events -- not working
//                        if isMultidayEvent {
//                            Text("Currently unable to add multiday events. Please keep your event within the 24-hour window of the selected date.")
//                                .foregroundColor(.red)
//                        }
                        Text("Roombee is currently unable to accommodate multi-day events. Please keep your event within the 24-hour window of the selected date.")
        //                            .font(.subheadline)
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                            
                    } // VStack
                }//form
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

                                print("Saving event with startTime: \(startTime), endTime: \(endTime)")

                                let newEvent = CalendarEvent(user_id: userId, eventTitle: viewModel.title, startTime: startTime, endTime: endTime)
                                onSave(newEvent)
                                NotificationService.shared.scheduleNotification(for: newEvent)
                                dismiss()
                            } else {
                                errorMessage = "No user information found."
                            }
                        }
                        .disabled(isMultidayEvent)
                        .foregroundColor(backgroundColor)
                    } // ToolbarItem
                } // toolbar
                

            }
        }
    }

    // Function to check if the event is a multiday event and update the state
    private func updateMultidayEventStatus() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: viewModel.dateEvent)
        
        if let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) {
            let isMultiday = viewModel.endTime > endOfDay
            if isMultidayEvent != isMultiday {
                print("Multiday status updated: \(isMultiday)")
                isMultidayEvent = isMultiday // Ensure this triggers the view update
            }
            print("Multiday event status: \(isMultidayEvent)")
            print("End of day boundary: \(endOfDay)")
        }
    }

    // Ensure that the endTime is not earlier than startTime and update the warning state
    private func checkAndFixEndTime() {
        if viewModel.endTime < viewModel.startTime {
            print("Error: endTime (\(viewModel.endTime)) is earlier than startTime (\(viewModel.startTime))! Fixing it...")
            viewModel.endTime = Calendar.current.date(byAdding: .hour, value: 1, to: viewModel.startTime) ?? viewModel.startTime
            showEndTimeWarning = true // Show warning when reset occurs
            print("New endTime: \(viewModel.endTime)")
        } else {
            showEndTimeWarning = false // Hide the warning if no reset is needed
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
    
    
    
    @State private var selectedEvent: CalendarEvent? // Track selected event
    @State private var showModal = false // modal visibility
    
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
                                        .onTapGesture {
                                            if showModal {
                                                showModal = false
                                                selectedEvent = nil
                                            }
                                        }

                                    
                                    //                                        .padding(1)
                                } // foreach
                            } //for each
                            
                        } //zstack
                        .onAppear {
                            // Scroll to 7 AM initially
                            value.scrollTo(7, anchor: .top)
                        }
                    } //scrollreader
                    
                } //scrollview
                addButton()
            } //vstack
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
        .overlay(
            Group {
                if let selectedEvent = selectedEvent, showModal {
                    EventModal(event: selectedEvent, isPresented: $showModal)
                        .transition(.scale)
                        .environmentObject(eventStore)
                        .environmentObject(auth)
                        .transition(.move(edge: .top))
                        .zIndex(1)
                }
            }
        )

//        .overlay(
//            // Display modal only if selectedEvent is not nil
//            if let selectedEvent = selectedEvent, showModal {
//                EventModal(event: selectedEvent, isPresented: $showModal)
//                    .transition(.move(edge: .top)) // Smooth transition
//                    .zIndex(1) // Ensure modal is on top
//            } else {
//                EmptyView()
//            }
//        )
        .onTapGesture {
            if showModal {
                showModal = false
                selectedEvent = nil
            }
        } //on tap
        
    } //body
    
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
            Mixpanel.mainInstance().track(event: "AddEvent", properties: ["userID": auth.user_id ?? "Unknown", "eventName": newEventViewModel.title])
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
            startTimer()
        }) {
            Group {
                NewEventView(viewModel: newEventViewModel) { newEvent in
                    if let userId = auth.user_id {
                        events.append(newEvent)
                        eventStore.addEvent(user_id: userId, newEvent)
                        skipFilter = true
                    } else {
                        errorMessage = "Error: No user information found."
                    }
                }
                .onAppear {
                    stopTimer()
                }
            }
        }

//        .sheet(isPresented: $showingAddEventSheet, onDismiss: {
//            // Resume the timer when the NewEventView is dismissed
//            startTimer()
//        }) {// Move this into a closure to ensure it doesn’t return a View
//            NewEventView(viewModel: newEventViewModel) { newEvent in
//                if let userId = auth.user_id {
//                    events.append(newEvent)
//                    eventStore.addEvent(user_id: userId, newEvent)
//                    skipFilter = true
//                } else {
//                    // Handle the case where user_id is nil (e.g., show an error message)
//                    errorMessage = "Error: No user information found."
//                }
//            }
//            .onAppear {
//                stopTimer()
//            }
//        }
        .padding()
    }
    
    // the appearance of each event on the calendar
    func eventCell(_ event: CalendarEvent, width: CGFloat) -> some View {
        let isUserEvent = eventStore.userEvents.contains(event)
//        let backgroundColor = isUserEvent ? LighterPurple : highlightYellow // Different color for roommate's events
        let backgroundColor: Color = {
            switch event.approved {
            case "true":
                return isUserEvent ? LighterPurple : highlightYellow
            case "false":
                return .gray
            case "let's talk":
                return ourOrange
            default:
                return isUserEvent ? pendingPurple : pendingYellow // 50% opacity for "none"
            }
        }()
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
                    Mixpanel.mainInstance().track(event: "DeletedEvent", properties: ["userID": auth.user_id ?? "Unknown", "eventName": newEventViewModel.title])
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
//            .opacity(event.approved == "none" ? 0.5 : 1.0) // Apply 50% opacity if approved is "none"
            .onTapGesture {
                withAnimation {
                    selectedEvent = event
                    showModal = true // Trigger the modal to show with animation
                }
            }
        } // vstack
    } // func eventCell

    
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
    

    
    
    struct EventModal: View {
        let event: CalendarEvent
        @Binding var isPresented: Bool
        @EnvironmentObject var eventStore: EventStore
        @EnvironmentObject var auth: AuthenticationViewModel

        @State private var selectedApproval: String? = nil
        @State private var deletedEvents: Set<String> = []

        
        var isUserEvent: Bool {
            eventStore.userEvents.contains(event)
        }
        var canModifyApproval: Bool {
            event.user_id != auth.user_id // ✅ Only non-creators can modify
        }

        
        var modalBackgroundColor: Color {
            switch event.approved {
            case "true":
                return isUserEvent ? LighterPurple : highlightYellow
            case "false":
                return .gray
            case "let's talk":
                return ourOrange
            default:
                return isUserEvent ? pendingPurple : pendingYellow // 50% opacity for "none"
            }
        } // modalbackground
        
        var body: some View {
            VStack {
                HStack{
                    Spacer()
                    // Delete Button
                    Button(action: {
                        deleteEvent()
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding()
                            .frame(width: 12, height: 12)
                    }
                    .disabled(event.user_id != auth.user_id) //disable if the current user is the creator
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 10)
                .padding(.trailing, 10)
                
                
//                EventModalContent(event: event, selectedApproval: $selectedApproval, canModifyApproval: $canModifyApproval)

            
                Text(event.eventTitle)
                    .font(.system(size: 20, weight: .bold))
//                    .padding(.top, 15)
                    .foregroundColor(.white)
                Text("\(event.startTime.formatted(.dateTime.hour().minute())) - \(event.endTime.formatted(.dateTime.hour().minute()))")
                    .font(.subheadline)
                    .foregroundColor(.white)


                HStack{ //spacing: 10
                    Button("Approve ✅") { //only the roommate who didnt make the event can change this event's status
                        selectedApproval = "true"
                    }
                    .disabled(!canModifyApproval) //disable if creator
                    .foregroundColor(selectedApproval == "true" ? backgroundColor : .white)
                    .padding()
                    .font(.system(size: 14))
                    .background(selectedApproval == "true" ? Color.white : highlightYellow)
                    .cornerRadius(10)
                    .opacity(canModifyApproval ? 1 : 0.5) //grays out button if creator
                    
//                    Button("Deny") {
//                        isPresented = false
//                    }
//                    .padding()
                    
                    Button("Let's Talk!💬") {
                        selectedApproval = "let's talk"
                     }
                    .disabled(!canModifyApproval)
                    .foregroundColor(selectedApproval == "Let's talk" ? backgroundColor : .white)
                    .padding()
                    .font(.system(size: 14))
                    .background(selectedApproval == "let's talk" ? Color.white : ourOrange)
                    .cornerRadius(10)
                    .opacity(canModifyApproval ? 1 : 0.5) //grays out button if creator
                    
                }
                .frame(width: 280, height: 40)
                .padding(.horizontal, 6)
                .padding(.top, 6)
                
                Button("Save and Close") {
                    if let approval = selectedApproval {
                        updateEventApproval(approval)
                    }
                    withAnimation{
                        isPresented = false
                    }
                }
                .foregroundColor(.white)
                .frame(width: 150, height: 30)
                .background(backgroundColor)
                .cornerRadius(10)
                .padding()
                
//                Text("This event was created by \(event.user_id)")
//                    .font(.subheadline)
//                    .padding()
//                    .foregroundColor(.white)
            }
            .frame(width: 280)
            .background(modalBackgroundColor)
            .cornerRadius(10)
            .shadow(radius: 10)
            .onAppear {
                selectedApproval = event.approved
            }
            .onTapGesture {
                //to prevent dismissing if user taps inside modal
            }
            .background(
                isPresented ? Color.black.opacity(0.0).edgesIgnoringSafeArea(.all).onTapGesture {
                    withAnimation{
                        isPresented = false
                    }
                } : nil
            )
            .transition(.scale)

        } //body
        
        private func deleteEvent() {
            // Ensure deletion logic integrates with your data flow
            eventStore.deleteEvent(eventId: event.id.uuidString)
            withAnimation{
                isPresented = false
            }
        }

        private func updateEventApproval(_ approval: String) {
//            eventStore.updateApproval(eventId: event.id.uuidString, newApprovalStatus: approval) { success, error in
//                if success {
//                    print("Approval updated successfully.")
//                } else {
//                    print("Failed to update approval: \(error?.localizedDescription ?? "Unknown error")")
//                }
//            }
            print("Approval updated successfully.")
        }

    } // eventmodal
    
    
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

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
