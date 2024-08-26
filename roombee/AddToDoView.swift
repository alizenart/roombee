//
//  AddToDoView.swift
//  roombee
//
//  Created by Nicole Liu on 4/15/24.
//

import SwiftUI

struct AddToDoView: View {
    @EnvironmentObject var todoManager: TodoViewModel
    @EnvironmentObject var auth: AuthenticationViewModel
    @State var newToDo = Tasks(userId: "", todoTitle: "", todoPriority: "low", todoCategory: "none")
    var onCommit: (_ newToDo: Tasks) -> Void
    let options = ["low", "med", "high"]
    let categoryOptions = ["none", "shopping", "chores"]
    @State private var selectedOption = 0
    @State var selectedCategory = 0
    
    @Environment(\.dismiss) private var dismiss
    
    enum FocusableField: Hashable {
        case title
    }

    @FocusState private var focusedField: FocusableField?

    private func add() {
        
        onCommit(newToDo)
        todoManager.addToDo(todoID: newToDo.id,
                            userId: auth.user_id ?? "80003",
                            hiveCode: auth.hive_code,
                            todoTitle: newToDo.todoTitle,
                            todoPriority: newToDo.todoPriority,
                            todoCategory: newToDo.todoCategory,
                            todoStatus: String(newToDo.status))
        dismiss()
    }
    
    private func cancel() {
        dismiss()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                Form {
                    TextField("Title", text: $newToDo.todoTitle)
                        .focused($focusedField, equals: .title)
                    Section(header: Text("Priority")) {
                        Picker(selection: $selectedOption, label: Text("")) {
                            ForEach(0..<options.count, id: \.self) { index in
                                Text(self.options[index]).tag(index)
                                    .frame(minHeight: 50, alignment: .center)
                            }
                        }
                        Picker(selection: $selectedCategory, label: Text("")) {
                            ForEach(0..<categoryOptions.count, id: \.self) { index in
                                Text(self.categoryOptions[index]).tag(index)
                                    .frame(minHeight: 50, alignment: .center)
                            }
                        }
                    }
                    .onChange(of: selectedCategory) { newValue in
                        switch newValue {
                        case 0:
                            newToDo.todoCategory = "none"
                        case 1:
                            newToDo.todoCategory = "shopping"
                        case 2:
                            newToDo.todoCategory = "chores"
                        default:
                            break
                        }
                    }
                    .onChange(of: selectedOption) { newValue in
                        switch newValue {
                        case 0:
                            newToDo.todoPriority = "low"
                        case 1:
                            newToDo.todoPriority = "medium"
                        case 2:
                            newToDo.todoPriority = "urgent"
                        default:
                            break
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("New Reminder")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: cancel) {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: add) {
                            Text("Add")
                        }
                        .disabled(newToDo.todoTitle.isEmpty)
                    }
                }
                .onAppear {
                    focusedField = .title
                }
            }
        }
    }
}

struct AddToDoView_Previews: PreviewProvider {
    static var previews: some View {
        AddToDoView { todo in
            print("You added a new reminder titled \(todo.todoTitle)")
        }
    }
}
