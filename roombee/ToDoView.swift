//
//  todolist.swift
//  roombee
//
//  Created by Nicole Liu on 4/15/24.
//

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
            List($tasks) {$task in
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
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: addview) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New Reminder")
                        }
                    }
                    Spacer()
                }
            }
            .sheet(isPresented: $addpresent) {
                AddToDoView { task in
                    tasks.append(task)
                }
            }
        }
    }
}

struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoView()
    }
}
