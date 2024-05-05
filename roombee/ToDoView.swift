

import SwiftUI

struct ToDoView: View {
    @State private var tasks = Tasks.samples
    @State
    private var addpresent = false
    
    private func addview() {
        addpresent.toggle()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color.black
                    .ignoresSafeArea()
                
                List {
                    // $ used for binding
                    ForEach($tasks, id: \.self) {$task in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 230 / 255, green: 217 / 255, blue: 197 / 255))
                            .frame(height: 50)
                            .overlay(
                                HStack {
                                    Image(systemName: task.status
                                          ? "largecircle.fill.circle"
                                          : "circle")
                                    .imageScale(.large)
                                    .foregroundColor(.accentColor)
                                    .onTapGesture {
                                        task.status.toggle()
                                    }
                                    Text(task.title)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                    .padding()
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    // $ for wrapping
                    .onDelete { indexSet in
                        $tasks.wrappedValue.remove(atOffsets: indexSet)
                        
                    }
                } // List
                
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button(action: addview) {
                            ZStack {
                                hexagonShape()
                                    .fill(Color(red: 221 / 255, green: 132 / 255, blue: 67 / 255))
                                    .frame(width: 40, height: 40)
                                Text("+")
                                    .foregroundColor(.white)
                                    .fontWeight(.heavy
                                    )
                                    .font(.system(size: 25
                                                 ))
                                    .padding(.bottom, 5)
                                
                            }
                        }
                        Spacer()
                    }
                }// toolbar
                // appending new task to list
                .sheet(isPresented: $addpresent) {
                    AddToDoView { task in
                        tasks.append(task)
                    }
                }// sheet
            }//zstack
        } // nav view
    } // body
}



struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoView()
    }
}



//
//import SwiftUI
//
//struct ToDoView: View {
//    @State private var tasks = Task.samples
//    @State
//    private var addpresent = false
//
//    private func addview() {
//        addpresent.toggle()
//    }
//
//    var body: some View {
//        NavigationView {
//            List($tasks) {$task in
//                HStack {
//                    Image(systemName: task.status
//                          ? "largecircle.fill.circle"
//                          : "circle")
//                    .imageScale(.large)
//                    .foregroundColor(.accentColor)
//                    .onTapGesture {
//                        task.status.toggle()
//                    }
//                    Text(task.title)
//                }
//            }
//            .toolbar {
//                ToolbarItemGroup(placement: .bottomBar) {
//                    Button(action: addview) {
//                        HStack {
//                            Image(systemName: "plus.circle.fill")
//                            Text("New Reminder")
//                        }
//                    }
//                    Spacer()
//                }
//            }
//            .sheet(isPresented: $addpresent) {
//                AddToDoView { task in
//                    tasks.append(task)
//                }
//            }
//        }
//    }
//}
//
//struct TodoView_Previews: PreviewProvider {
//    static var previews: some View {
//        ToDoView()
//    }
//}

//
//  todolist.swift
//  roombee
//
//  Created by Nicole Liu on 4/15/24.
//
