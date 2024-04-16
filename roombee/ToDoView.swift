//
//  todolist.swift
//  roombee
//
//  Created by Nicole Liu on 4/15/24.
//

import SwiftUI

struct todolist: View {
    @State 
    private var todos = Tasks.samples
    
    @State
    private var addpresent = false
    
    private func addview() {
        addpresent.toggle()
    }
    
    var body: some View {
        List($todos) {$todo in
            HStack {
                Image(systemName: todo.status
                      ? "largecircle.fill.circle"
                      : "circle")
                .imageScale(.large)
                .foregroundColor(.accentColor)
                .onTapGesture {
                    todo.status.toggle()
                }
                Text(todo.title)
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: addview) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New Reminder")
                        }
                    }
                    Spacer()}
                
            }
            .sheet(isPresented: $addpresent) {
                  addview { todo in
                      todos.append(todo)
                  }
            }
        }
    }
}


struct ToDoView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      todolist()
    }
  }
}
