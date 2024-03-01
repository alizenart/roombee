//
//  CalendarView.swift
//  roombee
//
//  Created by Adwait Ganguly on 10/7/23.
//

import SwiftUI

struct Event: Identifiable {
    let id = UUID()
    var startDate: Date
    var endDate: Date
    var title: String
}

class NewEventViewModel: ObservableObject {
  @Published var title: String = ""
  @Published var startDate: Date = Date()
  @Published var endDate: Date = Date()
}

struct NewEventView: View {
  @ObservedObject var viewModel: NewEventViewModel
  var onSave: (Event) -> Void
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    NavigationView {
      Form {
        TextField("Title", text: $viewModel.title)
        DatePicker("Start Time", selection: $viewModel.startDate, displayedComponents: .hourAndMinute).datePickerStyle(WheelDatePickerStyle())
        DatePicker("End Time", selection: $viewModel.endDate, displayedComponents: .hourAndMinute).datePickerStyle(WheelDatePickerStyle())
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
            let newEvent = Event(startDate: viewModel.startDate, endDate: viewModel.endDate, title: viewModel.title)
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
        VStack(alignment: .leading) {
            
            // Date headline
            Text(title).bold()
//            HStack {
//                Text(date.formatted(.dateTime.day().month()))
//                    .bold()
//                Text(date.formatted(.dateTime.year()))
//            }
//            .font(.title)
//            Text(date.formatted(.dateTime.weekday(.wide)))
            
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
          .background(Color.red)
          .foregroundColor(.black)
          .cornerRadius(8)
          
        }
        .padding()
    }
    
  func addNewEvent() {
    
  }
    
  func eventCell(_ event: Event) -> some View {
      
      let duration = event.endDate.timeIntervalSince(event.startDate)
      let height = duration / 60 / 60 * hourHeight
      
      let calendar = Calendar.current
      let hour = calendar.component(.hour, from: event.startDate)
      let minute = calendar.component(.minute, from: event.startDate)
      let offset = Double(hour-7) * (hourHeight)
//                      + Double(minute)/60 ) * hourHeight
      
      print(hour, minute, Double(hour-7) + Double(minute)/60 )

      return VStack(alignment: .leading) {
          Text(event.startDate.formatted(.dateTime.hour().minute()))
          Text(event.title).bold()
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
