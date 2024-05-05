//
//  todolist.swift
//  roombee
//
//  Created by Nicole Liu on 4/15/24.
//

import SwiftUI

struct ToDoView: View {
    @State private var tasks = Task.samples
    @State
    private var addpresent = false
    
    private func addview() {
        addpresent.toggle()
    }
    
    var body: some View {
        NavigationView {
            List {
                // $ used for binding
                ForEach($tasks, id: \.self) {$task in
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
                // $ for wrapping
                .onDelete { indexSet in
                    $tasks.wrappedValue.remove(atOffsets: indexSet)
                    
                }
            }
            /*
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
            */
            // add button for new tasks
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
            // appending new task to list
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
