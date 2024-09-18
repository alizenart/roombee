//
//  HomepageContent.swift
//  roombee
//
//  Created by Ziye Wang on 4/15/24.
//

import SwiftUI


struct HomepageContent: View {
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var auth: AuthenticationViewModel
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var selectedDateManager: SelectedDateManager
    @EnvironmentObject var toggleManager: ToggleViewModel
    @EnvironmentObject var todoManager: TodoViewModel
    @EnvironmentObject var agreementManager: RoommateAgreementHandler
    
    @Binding var myStatusToggleSleeping: Bool
    @Binding var myStatusToggleInRoom: Bool
    @Binding var roomieStatusToggleSleeping: Bool
    @Binding var roomieStatusToggleInRoom: Bool
    @State private var isShowingCalendarPopup: Bool = false
    
    @Binding var isInitialLoad: Bool
    
    @State private var pollingTimer: Timer?
    
    @State private var weekOffset: Int = 0


    var calGrid: GridView
    var yourStatus: StatusView?
    var roomStatus: StatusView?
    
    var schedCara: DatesCarousel {
        let dates = generateDates(startingFrom: selectedDateManager.SelectedDate, count: 7, weekOffset: weekOffset)
        return DatesCarousel(dates: dates, onDateSelected: { date in
            selectedDateManager.SelectedDate = date
            print("Original weekOffset is: \(weekOffset)")
            
            // bug resolved
            weekOffset = 0
            print("WeekOffset reset to: \(weekOffset)")
            
        }, onSwipeLeft: {
            weekOffset += 1 // Move to next week
            print("After swiping left, weekOffset is: \(weekOffset)")
        }, onSwipeRight: {
            weekOffset -= 1 // Move to previous week
            print("After swiping right, weekOffset is: \(weekOffset)")
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
                            .padding(.top, 20)
                        
                        schedCara.environmentObject(selectedDateManager)
                            .padding()
                        calGrid.padding([.leading, .trailing], 20)
                    }
                }
                        
            }
        }
        .onChange(of: myStatusToggleSleeping) { newValue in
            print("myStatusToggleSleeping changed to \(newValue)")
            // Add any additional logic here if needed
        }

        .onChange(of: roomieStatusToggleSleeping) { newValue in
            print("roomieStatusToggleSleeping changed to \(newValue)")
        }
        .onChange(of: auth.roommate_id) { newValue in
            if let userId = auth.user_id {
                fetchMyInitialToggleState(userId: userId)
            }

            if let roommateId = auth.roommate_id {
                fetchRoomieInitialToggleState(userId: roommateId)
                startRoomieStatusPolling(userId: roommateId)
            }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("UserSignedOut"), object: nil, queue: .main) { _ in
                stopRoomieStatusPolling()
            }
            
            NotificationService.shared.requestPerm()
            NotificationService.shared.todoNotif()
        }
        .onAppear(perform: {
            //loading Roommate information
            if let userId = auth.user_id {
                fetchMyInitialToggleState(userId: userId)
            }

            if let roommateId = auth.roommate_id {
                fetchRoomieInitialToggleState(userId: roommateId)
                startRoomieStatusPolling(userId: roommateId)
            }
            
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("UserSignedOut"), object: nil, queue: .main) { _ in
                stopRoomieStatusPolling()
            }
            
            NotificationService.shared.requestPerm()
            NotificationService.shared.todoNotif()
        })
        .onChange(of: isShowingCalendarPopup) { newValue in
                    if newValue {
                        // Calendar popup is showing, pause polling
                        stopRoomieStatusPolling()
                    } else {
                        // Calendar popup dismissed, resume polling
                        if let roommateId = auth.roommate_id {
                            fetchRoomieInitialToggleState(userId: roommateId)
                            startRoomieStatusPolling(userId: roommateId)
                        }
                    }
                }
    }
    
    private func fetchMyInitialToggleState(userId: String) {
        toggleManager.fetchToggles(userId: userId) { toggles, error in
            if let toggles = toggles, let firstToggle = toggles.first {
                DispatchQueue.main.async {
                    myStatusToggleSleeping = (firstToggle.isSleeping != 0)
                    myStatusToggleInRoom = (firstToggle.inRoom != 0)
                }
            } else if let error = error {
                print("error fetching toggles: \(error)")
            }
        }
        isInitialLoad = false
    }

    private func startRoomieStatusPolling(userId: String) {
        // Invalidate existing timer to ensure we don't create multiple instances
        pollingTimer?.invalidate()
        
        // Create a new Timer that calls `fetchRoomieInitialToggleState` every 5 seconds
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.fetchRoomieInitialToggleState(userId: userId)
        }
    }

    private func fetchRoomieInitialToggleState(userId: String) {
        toggleManager.fetchToggles(userId: userId) { toggles, error in
            if let toggles = toggles, let firstToggle = toggles.first {
                DispatchQueue.main.async {
                    roomieStatusToggleSleeping = (firstToggle.isSleeping != 0)
                    roomieStatusToggleInRoom = (firstToggle.inRoom != 0)
                }
            } else if let error = error {
                print("error fetching toggles: \(error)")
            }
        }
    }

    private func stopRoomieStatusPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
}


struct StatusView: View {
    @State var title: String
    @State var canToggle: Bool
    @Binding var isSleeping: Bool
    @Binding var inRoom: Bool
    @State private var hasLoaded = false // Flag to check if initial data has loaded
    @EnvironmentObject var toggleManager: ToggleViewModel
    var userId: String
    @Binding var isInitialLoad: Bool
    @EnvironmentObject var auth: AuthenticationViewModel
    
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
                if auth.user_id != nil && auth.roommate_id != nil {
                    HStack {
                        Toggle(isOn: $isSleeping, label: { bedIcon })
                            .disabled(!canToggle)
                            .onChange(of: isSleeping) { isOn in
                                if hasLoaded && canToggle { // Only trigger API call if the initial load is done and toggling is allowed
                                    toggleManager.changeToggleState(userId: userId, state: "is_sleeping")
                                }
                            }
                    }
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Toggle(isOn: $inRoom, label: { roomIcon })
                            .disabled(!canToggle)
                            .onChange(of: inRoom) { isOn in
                                if hasLoaded && canToggle { // Only trigger API call if the initial load is done and toggling is allowed
                                    toggleManager.changeToggleState(userId: userId, state: "in_room")
                                }
                            }
                    }
                    .padding(.horizontal, 20)
                } else {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(LighterPurple)
                        .aspectRatio(1.0, contentMode: .fit)
                        .overlay(
                            Text("Add roommate to see toggles! <--")
                                .font(.footnote)
                                .foregroundColor(creamColor)
                                .padding()
                        )
                        .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            // Set hasLoaded to true only after initial render
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                hasLoaded = true
            }
        }
    }
}

struct DatesCarousel: View {
    @EnvironmentObject var selectedDateManager: SelectedDateManager
    var dates: [Date]
    var onDateSelected: (Date) -> Void

    var onSwipeLeft: () -> Void
    var onSwipeRight: () -> Void

//    @State private var dragOffset: CGFloat = 0 // Track the current drag offset

    private let swipeThreshold: CGFloat = 50 // Minimum distance for a swipe gesture to be recognized

    var body: some View {
        VStack {
            Text("Schedules")
                .font(.system(size: 25))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)

            HStack {
                ForEach(dates, id: \.self) { date in
                    DateToggle(date: date, today: Calendar.current.isDateInToday(date)) {
                        onDateSelected(date)
                    }
                }
            }
//            .offset(x: dragOffset) // Apply drag offset for animation
            .gesture(
                DragGesture()
                    .onChanged { value in
//                        dragOffset = value.translation.width // Update drag offset during drag
                    }
                    .onEnded { value in
                        if value.translation.width < -swipeThreshold {
                            // Swipe left
                            withAnimation(.easeInOut) { // Animate swipe action
//                                dragOffset = -300 // Slide left animation
                                onSwipeLeft()
//                                dragOffset = 0 // Reset position
                            }
                        } else if value.translation.width > swipeThreshold {
                            // Swipe right
                            withAnimation(.easeInOut) { // Animate swipe action
//                                dragOffset = 300 // Slide right animation
                                onSwipeRight()
//                                dragOffset = 0 // Reset position
                            }
                        } else {
                            withAnimation(.easeInOut) {
//                                dragOffset = 0 // Reset position if swipe not recognized
                            }
                        }// else
                    } //onEnded
            ) // .gesture
        }
    }
}





func generateDates(startingFrom startDate: Date, count: Int, weekOffset: Int) -> [Date] {
    var dates = [Date]()
    var current = startDate

    let calendar = Calendar.current
    let weekday = calendar.component(.weekday, from: current)
    let daysToGoBack = weekday - calendar.firstWeekday
    if let lastSunday = calendar.date(byAdding: .day, value: -daysToGoBack, to: current) {
        current = lastSunday
    }

    // Adjust the start date by the weekOffset
    if let adjustedStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: current) {
        current = adjustedStart
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
    HomepageContent(
        myStatusToggleSleeping: .constant(true),
        myStatusToggleInRoom: .constant(true),
        roomieStatusToggleSleeping: .constant(true),
        roomieStatusToggleInRoom: .constant(true),
        isInitialLoad: .constant(true),
        calGrid: GridView(cal: CalendarView(title: "Me")),
        yourStatus: StatusView(title: "Me:", canToggle: true, isSleeping: .constant(false), inRoom: .constant(false), userId: "80003", isInitialLoad: .constant(true)),
        roomStatus: StatusView(title: "Roommate:", canToggle: false, isSleeping: .constant(false), inRoom: .constant(false), userId: "80002", isInitialLoad: .constant(true))
    )
    .environmentObject(EventStore())
    .environmentObject(AuthenticationViewModel())
    .environmentObject(NavManager())
    .environmentObject(ToggleViewModel())
    .environmentObject(TodoViewModel())
    .environmentObject(RoommateAgreementHandler())
}
