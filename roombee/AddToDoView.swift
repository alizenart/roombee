////
////  AddToDoView.swift
////  roombee
////
////  Created by Nicole Liu on 4/15/24.
////
//
//import SwiftUI
//
//
//struct AddToDoView: View {
//    @State
//    private var newToDo = Task(title:"")
//    var onCommit: (_ newToDo: Task) -> Void
//    
//    @Environment(\.dismiss)
//    private var dismiss
//    
//    enum FocusableField: Hashable {
//        case title}
//
//    @FocusState
//    private var focusedField: FocusableField?
//
//    private func add() {
//        onCommit(newToDo)
//        dismiss()
//    }
//    
//    private func cancel() {
//        dismiss()
//    }
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                TextField("Title", text: $newToDo.title)
//                    .focused($focusedField, equals: .title)
//            }
//            .navigationTitle("New Reminder")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button(action: cancel) {
//                        Text("Cancel")
//                    }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button(action: add) {
//                        Text("Add")}
//                    .disabled(newToDo.title.isEmpty)
//                }
//            }
//            .onAppear {
//                focusedField = .title
//            }
//        }
//    }
//}
//
//struct AddReminderView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddToDoView { todo in
//            print("You added a new reminder titled \(todo.title)")
//        }
//    }
//}

//
//  AddToDoView.swift
//  roombee
//
//  Created by Nicole Liu on 4/15/24.
//

import SwiftUI


struct AddToDoView: View {
    @State
    private var newToDo = Tasks(title:"", priority:.chillin, category: .none)
    var onCommit: (_ newToDo: Tasks) -> Void
    
    @Environment(\.dismiss)
    private var dismiss
    
    enum FocusableField: Hashable {
        case title}

    @FocusState
    private var focusedField: FocusableField?

    private func add() {
        onCommit(newToDo)
        dismiss()
    }
    
    private func cancel() {
        dismiss()
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $newToDo.title)
                    .focused($focusedField, equals: .title)
            }
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
                        Text("Add")}
                    .disabled(newToDo.title.isEmpty)
                }
            }
            .onAppear {
                focusedField = .title
            }
        }
    }
}

struct AddReminderView_Previews: PreviewProvider {
    static var previews: some View {
        AddToDoView { todo in
            print("You added a new reminder titled \(todo.title)")
        }
    }
}
